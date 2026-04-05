import SwiftUI

struct MeasurementChartCard<ChartContent: View>: View {
    let title: String?
    let value: String
    let subtitle: String?
    let tint: Color
    
    @Binding var range: MeasurementChartRange
    
    private let chartContent: () -> ChartContent
    
    init(
        title: String? = nil,
        value: String,
        subtitle: String? = nil,
        tint: Color,
        range: Binding<MeasurementChartRange>,
        @ViewBuilder chartContent: @escaping () -> ChartContent
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.tint = tint
        _range = range
        self.chartContent = chartContent
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker("Time Range", selection: $range) {
                ForEach(MeasurementChartRange.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .tint(tint)
            
            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .foregroundStyle(.primary)
                        .headline(.semibold, design: .rounded)
                }
                
                Text(value)
                    .largeTitle(.bold, design: .rounded)
                    .foregroundStyle(.primary)
                
                if let subtitle {
                    Text(subtitle)
                        .secondary()
                }
            }
            
            chartContent()
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 24))
    }
}
