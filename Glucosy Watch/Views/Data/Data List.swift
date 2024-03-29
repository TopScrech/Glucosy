import SwiftUI

struct DataList: View {
    private let type: LocalizedStringKey
    private let data: [Glucose]
    
    init(_ type: LocalizedStringKey, data: [Glucose]) {
        self.type = type
        self.data = data
    }
    
    var body: some View {
        List {
            if data.count > 0 {
                ForEach(data, id: \.self) { glucose in
                    HStack {
                        Text(glucose.value > -1 ? glucose.value.units : "…")
                            .bold()
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(glucose.id)
                                .foregroundStyle(.tertiary)
                            
                            Text(glucose.date.shortDateTime)
                                .foregroundStyle(.secondary)
                        }
                        .footnote()
                    }
                }
            }
        }
        .navigationTitle(type)
    }
}

#Preview {
    NavigationView {
        DataList("Factory Values", data: History.test.factoryValues)
    }
}
