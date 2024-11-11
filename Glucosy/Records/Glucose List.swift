import SwiftUI

struct GlucoseList: View {
    @Environment(HealthKit.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.GlucoseRecords) { record in
                GlucoseCard(record)
            }
        }
    }
}

#Preview {
    GlucoseList()
        .environment(HealthKit())
}
