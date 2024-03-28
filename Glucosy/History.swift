import Foundation

@Observable
final class History {
    var values:           [Glucose] = []
    var rawValues:        [Glucose] = []
    var rawTrend:         [Glucose] = []
    var factoryValues:    [Glucose] = []
    var factoryTrend:     [Glucose] = []
    var nightscoutValues: [Glucose] = []
    
    // HealthKit
    var glucose:         [Glucose]         = []
    var insulin:         [InsulinDelivery] = []
    var carbs:           [Carbohydrates]   = []
    var bmi:             [BMI]             = []
    var bodyMass:        [BodyMass]        = []
    var bodyTemperature: [BodyTemperature] = []
}
