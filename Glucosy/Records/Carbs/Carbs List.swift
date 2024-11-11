import SwiftUI

struct CarbsList: View {
    @Environment(HealthKit.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.carbsRecords) { record in
                CarbsCard(record)
            }
        }
    }
}

#Preview {
    CarbsList()
}
