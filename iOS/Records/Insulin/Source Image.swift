import SwiftUI

struct SourceImage: View {
    private let source: String
    
    init(_ source: String) {
        self.source = source
    }
    
    private var image: ImageResource? {
        switch source {
        case "com.apple.Health": .appleHealth
        default: nil
        }
    }
    
    var body: some View {
        Group {
            if let image {
                Image(image)
                    .resizable()
            } else {
                Image(systemName: "questionmark.app.dashed")
            }
        }
        .frame(width: 32, height: 32)
    }
}

#Preview {
    SourceImage("com.apple.Health")
}
