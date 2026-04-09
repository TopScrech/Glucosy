import SwiftUI
import SwiftData

struct SavedPenRow: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var pen: SavedPen
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(pen.title)
            
            if !pen.serial.isEmpty && pen.serial != pen.title {
                Text(pen.serial)
                    .secondary()
            }
            
            Picker("Type", selection: $pen.insulinType) {
                ForEach(InsulinType.allCases) {
                    Text($0.title)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .onChange(of: pen.insulinType) {
            try? modelContext.save()
        }
    }
}
