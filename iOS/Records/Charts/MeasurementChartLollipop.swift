import ScrechKit

struct MeasurementChartLollipop: View {
    let point: MeasurementChartPoint
    let value: String
    let tint: Color
    let lineX: CGFloat
    let pointY: CGFloat
    let plotFrame: CGRect
    let chartWidth: CGFloat
    
    private let labelWidth = 118.0
    private let labelVerticalPadding = 6.0
    private let lineWidth = 2.0
    private let markerBorderSize = 14.0
    private let markerSize = 8.0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(tint)
                .frame(width: lineWidth, height: plotFrame.height)
                .position(x: lineX, y: plotFrame.midY)
            
            Circle()
                .fill(.background)
                .frame(width: markerBorderSize, height: markerBorderSize)
                .position(x: lineX, y: pointY)
            
            Circle()
                .fill(tint)
                .frame(width: markerSize, height: markerSize)
                .position(x: lineX, y: pointY)
            
            VStack {
                Text(point.date, format: .dateTime.month(.abbreviated).day())
                    .caption()
                    .secondary()
                
                Text(value)
                    .headline(.semibold, design: .rounded)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .padding(.vertical, labelVerticalPadding)
            .frame(width: labelWidth)
            .modifier(MeasurementChartLollipopLabelBackground())
            .offset(x: labelOffset)
        }
        .padding(2)
    }
    
    private var labelOffset: CGFloat {
        let maxOffset = max(0, chartWidth - labelWidth)
        let centeredOffset = lineX - labelWidth / 2
        
        return max(0, min(maxOffset, centeredOffset))
    }
}
