import ScrechKit

struct InsulinRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    let onScanPen: (() -> Void)?
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            Section {
                InsulinChart(vm.insulinRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(vm.insulinDays) { day in
                Section {
                    ForEach(day.records) {
                        InsulinRecordCard($0)
                    }
                } header: {
                    InsulinSectionHeaderView(day: day)
                }
            }
        }
        .navigationTitle("Insulin Delivery")
        .task {
            _ = try? await vm.reloadInsulinRecords(fullHistory: true, ifStale: true)
        }
        .refreshable {
            _ = try? await vm.reloadInsulinRecords(fullHistory: true)
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
