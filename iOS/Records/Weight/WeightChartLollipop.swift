import ScrechKit

struct WeightChartLollipop: View {
    let point: MeasurementChartPoint
    let lineX: CGFloat
    let pointY: CGFloat
    let plotFrame: CGRect
    let chartWidth: CGFloat
    
    private let labelWidth: CGFloat = 118
    private let labelVerticalPadding: CGFloat = 6
    private let lineWidth: CGFloat = 2
    private let markerBorderSize: CGFloat = 14
    private let markerSize: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.blue)
                .frame(width: lineWidth, height: plotFrame.height)
                .position(x: lineX, y: plotFrame.midY)
            
            Circle()
                .fill(.background)
                .frame(width: markerBorderSize, height: markerBorderSize)
                .position(x: lineX, y: pointY)
            
            Circle()
                .fill(.blue)
                .frame(width: markerSize, height: markerSize)
                .position(x: lineX, y: pointY)
            
            VStack {
                Text(point.date, format: .dateTime.month(.abbreviated).day())
                    .caption()
                    .secondary()
                
                Text("\(Utils.formatTenths(point.value)) kg")
                    .headline(.semibold, design: .rounded)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .padding(.vertical, labelVerticalPadding)
            .frame(width: labelWidth)
            .background(.regularMaterial, in: .rect(cornerRadius: 8))
            .offset(x: labelOffset)
        }
    }
    
    private var labelOffset: CGFloat {
        let maxOffset = max(0, chartWidth - labelWidth)
        let centeredOffset = lineX - labelWidth / 2
        
        return max(0, min(maxOffset, centeredOffset))
    }
}
