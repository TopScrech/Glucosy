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
        default: nil
        }
    }
    
    var body: some View {
        Group {
            if let image {
                Image(image)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                Image(systemName: "questionmark.app.dashed")
            }
        }
        .frame(width: 16, height: 16)
    }
}

#Preview {
    SourceImage("com.apple.Health")
}
