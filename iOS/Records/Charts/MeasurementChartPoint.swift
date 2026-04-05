import Foundation

struct MeasurementChartPoint: Identifiable {
    let date: Date
    let value: Double
    
    var id: Date {
        date
    }
}
