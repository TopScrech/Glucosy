import SwiftUI
import CoreNFC

struct TodayView: View {
    @StateObject private var nfcReader = NFCReader()
    
    var body: some View {
        VStack {
            if let doseRecords = nfcReader.doseRecords {
                List(doseRecords, id: \ .self) { record in
                    Text(record)
                }
            } else {
                Text("No data read yet")
            }
            
            Button("Scan NovoPen") {
                nfcReader.beginScanning()
            }
            .padding()
        }
    }
}

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var doseRecords: [String]?
    private var nfcSession: NFCTagReaderSession?
    
    func beginScanning() {
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Hold your iPhone near the NovoPen"
        nfcSession?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tags found.")
            return
        }
        
        session.connect(to: tag) { error in
            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            if case let .iso7816(nfcTag) = tag {
                self.executePenProtocol(tag: nfcTag, session: session)
            } else {
                session.invalidate(errorMessage: "Unsupported tag type.")
            }
        }
    }
    
    private func executePenProtocol(tag: NFCISO7816Tag, session: NFCTagReaderSession) {
        let applicationSelect = createAPDU(command: 0xA4, p1: 0x04, p2: 0x00, data: Data([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01]))
        sendAPDU(tag: tag, session: session, apdu: applicationSelect) { response in
            let readData = self.createAPDU(command: 0xB0, p1: 0x00, p2: 0x00, data: Data(), expectedLength: 21)
            self.sendAPDU(tag: tag, session: session, apdu: readData) { response in
                let decodedString = String(data: response, encoding: .utf8) ?? "Invalid Data"
                DispatchQueue.main.async {
                    self.doseRecords = [decodedString]
                }
                session.invalidate()
            }
        }
    }
    
    private func createAPDU(command: UInt8, p1: UInt8, p2: UInt8, data: Data, expectedLength: Int = -1) -> NFCISO7816APDU {
        return NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: command,
            p1Parameter: p1,
            p2Parameter: p2,
            data: data,
            expectedResponseLength: expectedLength
        )
    }
    
    private func sendAPDU(tag: NFCISO7816Tag, session: NFCTagReaderSession, apdu: NFCISO7816APDU, completion: @escaping (Data) -> Void) {
        tag.sendCommand(apdu: apdu) { response, sw1, sw2, error in
            guard error == nil, sw1 == 0x90, sw2 == 0x00 else {
                session.invalidate(errorMessage: "APDU command failed.")
                return
            }
            completion(response)
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Error", error.localizedDescription)
    }
}
