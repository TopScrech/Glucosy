import SwiftUI

struct RecordList: View {
    private var vm = HealthKit()
    
    var body: some View {
        List {
            Section {
                Text("Estimated HbA1c")
            }
            
            Section {
                Text("Glucose")
            }
            
            Section {
                Text("Insulin Delivery")
            }
            
            Section {
                Text("Carbs")
            }
        }
    }
}

#Preview {
    RecordList()
}
