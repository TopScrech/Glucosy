//import SwiftUI
//
//struct TemperatureList: View {
//    var body: some View {
//        Section {
//            DisclosureGroup("Body Temperature", isExpanded: $isExpandedTemperature) {
//                ForEach(history.bodyTemperature, id: \.self) { temperature in
//                    Text(temperature.value)
//                }
//                // TODO: .onDelete(perform: deleteTemperature)
//            }
//        } header: {
//            HStack {
//                Text("\(history.bodyTemperature.count) records")
//                    .bold()
//                
//                Spacer()
//                
//                NavigationLink("View all") {
//                    // TODO
//                }
//                .footnote()
//                .foregroundStyle(.latte)
//            }
//        }
//    }
//}
//
//#Preview {
//    TemperatureList()
//}
