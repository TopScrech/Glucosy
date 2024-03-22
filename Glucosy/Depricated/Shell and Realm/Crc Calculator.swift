//import SwiftUI
//
//struct CrcCalculator: View {
//    @State private var hexString = ""
//    @State private var crc = "0000"
//    @State private var computedCrc = "0000"
//    @State private var trailingCrc = true
//    
//    @FocusState private var focused: Bool
//    
//    func updateCRC() {
//        hexString = hexString.filter { $0.isHexDigit || $0 == " " }
//        var validated = hexString == "" ? "00" : hexString
//        validated = validated.replacingOccurrences(of: " ", with: "")
//        
//        if validated.count % 2 == 1 {
//            validated = "0" + validated
//        }
//        
//        if validated.count < 8 {
//            validated = String((String(repeating: "0", count: 8 - validated.count) + validated).suffix(8))
//        }
//        
//        let validatedBytes = validated.bytes
//        
//        if trailingCrc {
//            crc = Data(String(validated.suffix(4)).bytes.reversed()).hex
//            computedCrc = validatedBytes.dropLast(2).crc16.hex
//        } else {
//            crc = Data(String(validated.prefix(4)).bytes.reversed()).hex
//            computedCrc = validatedBytes.dropFirst(2).crc16.hex
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            TextField("Hexadecimal string", text: $hexString, axis: .vertical)
//                .textFieldStyle(.roundedBorder)
//                .footnote(design: .monospaced)
//                .truncationMode(.head)
//                .focused($focused)
//                .toolbar {
//                    ToolbarItem(placement: .keyboard) {
//                        Button("Done") {
//                            focused = false
//                        }
//                    }
//                }
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("CRC: \(crc == "0000" ? "---" : crc)")
//                    
//                    Text("Computed: \(crc == "0000" ? "---" : computedCrc)")
//                }
//                .foregroundColor(crc != "0000" && crc == computedCrc ? .green : .primary)
//                
//                Spacer()
//                
//                Toggle("Trailing CRC", isOn: $trailingCrc)
//                    .controlSize(.mini)
//                    .fixedSize()
//                    .onChange(of: trailingCrc) {
//                        updateCRC()
//                    }
//            }
//        }
//        .subheadline()
//        .onChange(of: hexString) {
//            updateCRC()
//        }
//    }
//}
