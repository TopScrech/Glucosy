import SwiftUI

// TODO
@ViewBuilder
func ListRow <T: CustomStringConvertible> (_ label: String, _ value: T, foregroundColor: Color? = .yellow) -> some View {
    let stringValue = value.description
    
    if !(stringValue.isEmpty || stringValue == "unknown") {
        HStack {
            Text(label)
            
            Spacer()
            
            Text(stringValue)
                .foregroundColor(foregroundColor)
        }
    } else {
        EmptyView()
    }
}
