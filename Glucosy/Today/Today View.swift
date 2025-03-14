import SwiftUI
import CoreNFC

// Took a basal dose
// HB1AC

struct TodayView: View {
    var body: some View {
        ContentView()
    }
}

#Preview {
    TodayView()
}

struct ContentView: View {
    @StateObject private var nfcReader = NFCReader()
    
    var body: some View {
        VStack {
            if let doseRecords = nfcReader.doseRecords {
                List(doseRecords, id: \.self) { record in
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

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var doseRecords: [String]?
    private var nfcSession: NFCNDEFReaderSession?
    
    func beginScanning() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NovoPen"
        nfcSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Error", error.localizedDescription)
        // Handle errors here, if needed
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print(messages)
        var records = [String]()
        
        for message in messages {
            for record in message.records {
                if let recordString = String(data: record.payload, encoding: .utf8) {
                    records.append(recordString)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.doseRecords = records
        }
    }
}
