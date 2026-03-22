import Foundation

enum NovoPenProtocol {
    static let commandCompleted = 0x9000
    static let selectInstruction = 0xA4
    static let readBinaryInstruction = 0xB0
    
    static let ndefTagApplicationSelect = Data([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01])
    static let capabilityContainerIdentifier = Data([0xE1, 0x03])
    static let ndefIdentifier = Data([0xE1, 0x04])
    
    static func applicationSelect() -> Data {
        createTransceivePayload(
            p1: 0x04,
            p2: 0x0C,
            data: ndefTagApplicationSelect,
            includeLe: true
        )
    }
    
    static func capabilityContainerSelect() -> Data {
        createTransceivePayload(
            p1: 0,
            p2: 0x0C,
            data: capabilityContainerIdentifier
        )
    }
    
    static func selectNDEF() -> Data {
        createTransceivePayload(
            p1: 0,
            p2: 0x0C,
            data: ndefIdentifier
        )
    }
    
    static func readBinary(offset: Int, length: Int) -> Data {
        var writer = ByteWriter()
        writer.writeUInt8(0)
        writer.writeUInt8(readBinaryInstruction)
        writer.writeUInt16(offset)
        writer.writeUInt8(length)
        return writer.data
    }
    
    static func retrieveInformation(invokeID: Int, configuration: Configuration) -> Apdu {
        var writer = ByteWriter()
        writer.writeUInt16(configuration.id)
        writer.writeUInt16(0)
        
        let request = EventRequest(
            handle: 0,
            currentTime: 0,
            type: EventReport.configurationNotification,
            data: writer.data
        )
        
        return Apdu(
            at: Apdu.prst,
            payload: DataApdu(
                invokeID: invokeID,
                choice: DataApdu.confirmedEventReport,
                payload: request.encoded()
            ).encoded()
        )
    }
    
    static func askInformation(invokeID: Int, handle: Int) -> Apdu {
        Apdu(
            at: Apdu.prst,
            payload: DataApdu(
                invokeID: invokeID,
                choice: DataApdu.simpleGetChosen,
                payload: ArgumentsSimple(handle: handle).encoded()
            ).encoded()
        )
    }
    
    static func confirmedAction(invokeID: Int, handle: Int = ConfirmedAction.storeHandle) -> Apdu {
        Apdu(
            at: Apdu.prst,
            payload: DataApdu(
                invokeID: invokeID,
                choice: DataApdu.confirmedAction,
                payload: ConfirmedAction
                    .allSegments(handle: handle, type: DataApdu.segmentGetInfo)
                    .encoded()
            ).encoded()
        )
    }
    
    static func transferAction(
        invokeID: Int,
        handle: Int = ConfirmedAction.storeHandle,
        actionType: Int = DataApdu.segmentTriggerTransfer,
        actionBytes: Data
    ) -> Apdu {
        Apdu(
            at: Apdu.prst,
            payload: DataApdu(
                invokeID: invokeID,
                choice: DataApdu.confirmedAction,
                payload: ConfirmedAction
                    .custom(handle: handle, type: actionType, bytes: actionBytes)
                    .encoded()
            ).encoded()
        )
    }
    
    static func transferAction(
        invokeID: Int,
        handle: Int = ConfirmedAction.storeHandle,
        segment: Int
    ) -> Apdu {
        transferAction(
            invokeID: invokeID,
            handle: handle,
            actionBytes: ConfirmedAction.segmentBytes(segment: segment)
        )
    }
    
    static func transferAllSegmentsAction(
        invokeID: Int,
        handle: Int = ConfirmedAction.storeHandle
    ) -> Apdu {
        transferAction(
            invokeID: invokeID,
            handle: handle,
            actionBytes: ConfirmedAction.allSegmentsBytes()
        )
    }
    
    static func confirmedTransfer(invokeID: Int, data: Data) -> Apdu {
        Apdu(
            at: Apdu.prst,
            payload: DataApdu(
                invokeID: invokeID,
                choice: 0x0201,
                payload: EventRequest(
                    handle: ConfirmedAction.storeHandle,
                    currentTime: -1,
                    type: EventReport.segmentDataNotification,
                    data: data
                ).encoded()
            ).encoded()
        )
    }
    
    static func eventRequestData(instance: Int, index: Int, count: Int, confirmed: Bool) -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(instance)
        writer.writeUInt16(0)
        writer.writeUInt16(index)
        writer.writeUInt16(0)
        writer.writeUInt16(count)
        writer.writeUInt8(0)
        writer.writeUInt8(confirmed ? 0x80 : 0)
        return writer.data
    }
    
    static func t4Update(_ bytes: Data) -> Data {
        var writer = ByteWriter()
        writer.writeUInt8(0)
        writer.writeUInt8(0xD6)
        writer.writeUInt16(0)
        writer.writeUInt8(bytes.count + 2)
        writer.writeUInt16(bytes.count)
        writer.writeData(bytes)
        return writer.data
    }
    
    static func acknowledgement() -> Data {
        t4Update(Data([0xD0, 0x00, 0x00]))
    }
    
    private static func createTransceivePayload(p1: Int, p2: Int, data: Data, includeLe: Bool = false) -> Data {
        var writer = ByteWriter()
        writer.writeUInt8(0)
        writer.writeUInt8(selectInstruction)
        writer.writeUInt8(p1)
        writer.writeUInt8(p2)
        writer.writeUInt8(data.count)
        writer.writeData(data)
        
        if includeLe {
            writer.writeUInt8(0)
        }
        
        return writer.data
    }
}
