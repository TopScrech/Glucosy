import SwiftUI

struct RecordList: View {
    @State private var vm = HealthKit()
    
    var body: some View {
        List {
            Section {
                Text("Estimated HbA1c")
            }
            
            Section {
                NavigationLink("Glucose") {
                    GlucoseList()
                        .environment(vm)
                }
            }
            
            Section {
                Text("Insulin Delivery")
            }
            
            Section {
                Text("Carbs")
            }
        }
        .task {
            vm.authorize { result in
                print("Auth status: \(result)")
                
                // TODO: Display Warning when false
            }
            
            vm.readGlucose()
        }
    }
}

#Preview {
    RecordList()
}
