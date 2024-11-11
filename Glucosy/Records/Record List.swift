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
                NavigationLink("Insulin Delivery") {
                    InsulinList()
                        .environment(vm)
                }
            }
            
            Section {
                NavigationLink("Carbs") {
                    CarbsList()
                        .environment(vm)
                }
            }
        }
        .task {
            vm.authorize { result in
                print("Auth status: \(result)")
                
                // TODO: Display Warning when false
            }
            
            vm.readGlucose()
            vm.readInsulin()
            vm.readCarbs()
        }
    }
}

#Preview {
    RecordList()
}
