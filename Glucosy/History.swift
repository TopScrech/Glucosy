import Foundation

@Observable
final class History {
    var values:                  [Glucose] = []
    var rawValues:               [Glucose] = []
    var rawTrend:                [Glucose] = []
    var factoryValues:           [Glucose] = []
    var factoryTrend:            [Glucose] = []
    var nightscoutValues:        [Glucose] = []
    
    // HealthKit
    var storedValues:            [Glucose] = []
    var insulinDeliveries:       [InsulinDelivery] = []
    var consumedCarbohydrates:   [Carbohydrates] = []
}
