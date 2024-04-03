import SwiftUI

// TODO
@ViewBuilder
func ListRow <T: CustomStringConvertible> (_ label: String, _ value: T, color: Color? = .yellow) -> some View {
    let stringValue = value.description
    
    if !(stringValue.isEmpty || stringValue == "unknown") {
        HStack {
            Text(label)
            
            Spacer()
            
            Text(stringValue)
                .foregroundColor(color)
        }
    } else {
        EmptyView()
    }
}
