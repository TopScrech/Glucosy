import SwiftUI

struct SourceImage: View {
    private let source: String
    
    init(_ source: String) {
        self.source = source
    }
    
    private var image: ImageResource? {
        switch source {
        case "com.apple.Health": .appleHealth
        case "com.i-sens.SmartLog2": .smartLog
        case "dev.topscrech.Glucosy": .glucosy
        case "dev.topscrech.DiaBLE": .diaBLE
        case "com.apple.shortcuts": .shortcuts
        case "com.mysugr.companion.mySugr": .mySugr
        case "com.dexcom.dexcomoneplus": .dexcomONE
        default: nil
        }
    }
    
    var body: some View {
        Group {
            if let image {
                Image(image)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(.clear)
            }
        }
        .frame(25)
    }
}

#Preview {
    SourceImage("com.apple.Health")
        .darkSchemePreferred()
}
