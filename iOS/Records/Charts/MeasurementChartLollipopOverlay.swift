import SwiftUI
import Charts

struct MeasurementChartLollipopOverlay: View {
    let proxy: ChartProxy
    let points: [MeasurementChartPoint]
    @Binding var selectedPoint: MeasurementChartPoint?
    let tint: Color
    let value: (MeasurementChartPoint) -> String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                if let selectedPoint,
                   let positionX = proxy.position(forX: selectedPoint.date),
                   let positionY = proxy.position(forY: selectedPoint.value) {
                    let plotFrame = geometry[proxy.plotAreaFrame]
                    let lineX = plotFrame.origin.x + positionX
                    let pointY = plotFrame.origin.y + positionY
                    
                    MeasurementChartLollipop(
                        point: selectedPoint,
                        value: value(selectedPoint),
                        tint: tint,
                        lineX: lineX,
                        pointY: pointY,
                        plotFrame: plotFrame,
                        chartWidth: geometry.size.width
                    )
                    .allowsHitTesting(false)
                }
                
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .gesture(
                        SpatialTapGesture()
                            .onEnded {
                                let point = findPoint(
                                    at: $0.location,
                                    geometry: geometry
                                )
                                
                                if selectedPoint?.date == point?.date {
                                    selectedPoint = nil
                                } else {
                                    selectedPoint = point
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged {
                                        selectedPoint = findPoint(
                                            at: $0.location,
                                            geometry: geometry
                                        )
                                    }
                            )
                    )
            }
        }
    }
    
    private func findPoint(
        at location: CGPoint,
        geometry: GeometryProxy
    ) -> MeasurementChartPoint? {
        let plotFrame = geometry[proxy.plotAreaFrame]
        let relativeX = location.x - plotFrame.origin.x
        
        guard let date = proxy.value(atX: relativeX) as Date? else {
            return nil
        }
        
        return points.min {
            abs($0.date.distance(to: date)) < abs($1.date.distance(to: date))
        }
    }
}
