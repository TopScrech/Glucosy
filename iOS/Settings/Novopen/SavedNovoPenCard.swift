import SwiftUI

struct SavedNovoPenCard: View {
    private let pen: SavedPen
    
    init(_ pen: SavedPen) {
        self.pen = pen
    }
    
    var body: some View {
        NavigationLink {
            SavedPenEditorView(pen)
        } label: {
            HStack {
                Text(pen.title)
                
                Spacer()
                
                Text(pen.insulinType.title)
                    .secondary()
            }
        }
    }
}
