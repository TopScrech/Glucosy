import SwiftData
import SwiftUI

struct SavedPenRow: View {
    @Bindable var pen: SavedPen
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(pen.title)
            
            if !pen.serial.isEmpty && pen.serial != pen.title {
                Text(pen.serial)
                    .foregroundStyle(.secondary)
            }
            
            Picker("Type", selection: $pen.insulinType) {
                ForEach(InsulinType.allCases) {
                    Text($0.title)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .onChange(of: pen.insulinType) { _, _ in
            try? modelContext.save()
        }
    }
}
