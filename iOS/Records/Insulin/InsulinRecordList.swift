import ScrechKit
import Algorithms

struct InsulinRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    let onScanPen: (() -> Void)?
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.insulinRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                InsulinChart(vm.insulinRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk) {
                            InsulinRecordCard($0)
                        }
                    }
                }
            }
        }
        .navigationTitle("Insulin Delivery")
        .refreshable {
            _ = try? await vm.reloadInsulinRecords()
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet(.insulin)
                .environment(vm)
        }
        .toolbar {
#if !os(visionOS)
            ToolbarItem(placement: .topBarTrailing) {
                if let onScanPen {
                    Button("Scan Pen", systemImage: "wave.3.right", action: onScanPen)
                }
            }
            
            if let _ = onScanPen, #available(iOS 26, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
#endif
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("plus") {
                    sheetNewRecord = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InsulinRecordList(onScanPen: {})
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
