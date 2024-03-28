import Foundation

extension Monitor {
    var deviceState: String {
        app.deviceState
    }
    
    var currentGlucose: Int {
        app.currentGlucose
    }
    
    var trendDelta: Int {
        app.trendDelta
    }
    
    var lastReadingDate: Date {
        app.lastReadingDate
    }
    
    var trendArrow: TrendArrow {
        app.trendArrow
    }
}
