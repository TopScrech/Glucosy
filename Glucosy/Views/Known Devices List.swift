import SwiftUI
import CoreBluetooth

struct KnownDevicesList: View {
    @Environment(AppState.self) private var app: AppState
    
    @AppStorage("known_devices_is_expanded") private var isExpanded = false
    
    private var knownDevices: [(key: String, value: (name: String, peripheral: CBPeripheral, isConnectable: Bool, isIgnored: Bool))] {
        app.main.bluetoothDelegate.knownDevices.sorted {
            $0.key < $1.key
        }
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(knownDevices, id: \.key) { uuid, device in
                HStack {
                    Text(device.name)
                        .callout()
                        .foregroundColor((app.device != nil) && uuid == app.device!.peripheral!.identifier.uuidString ? .yellow : .blue)
                        .onTapGesture {
                            // TODO: navigate to peripheral details
                            
                            if let peripheral = app.main.centralManager.retrievePeripherals(withIdentifiers: [UUID(uuidString: uuid)!]).first {
                                
                                if let appDevice = app.device {
                                    app.main.centralManager.cancelPeripheralConnection(appDevice.peripheral!)
                                }
                                
                                app.main.log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
                                app.main.settings.preferredTransmitter = .none
                                
                                app.main.bluetoothDelegate.centralManager(app.main.centralManager, didDiscover: peripheral, advertisementData: [:], rssi: 0)
                            }
                        }
                    
                    Spacer()
                    
                    if !device.isConnectable {
                        Image(systemName: "nosign")
                            .foregroundColor(.red)
                        
                    } else if device.isIgnored {
                        Image(systemName: "hand.raised.slash.fill")
                            .foregroundColor(.red)
                            .onTapGesture {
                                app.main.bluetoothDelegate.knownDevices[uuid]!.isIgnored.toggle()
                            }
                    }
                }
            }
        } label: {
            Text("Known devices: \(knownDevices.count)")
                .animation(.default, value: knownDevices.count)
        }
    }
}

#Preview {
    KnownDevicesList()
        .glucosyPreview()
}
