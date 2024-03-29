import SwiftUI

struct DataServiceList: View {
    private let type: LocalizedStringKey
    private let data: [Glucose]
    
    init(_ type: LocalizedStringKey, data: [Glucose]) {
        self.type = type
        self.data = data
    }
    
    var body: some View {
        List {
            ForEach(data, id: \.self) { glucose in
                HStack {
                    Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)")
                    
                    Spacer()
                    
                    Text(glucose.value.units)
                        .bold()
                }
                .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(type)
    }
}


#Preview {
    NavigationView {
        DataServiceList("HealthKit", data: History.test.factoryValues)
    }
}
