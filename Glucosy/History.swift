import Foundation

@Observable
final class History {
    var values:                  [Glucose] = []
    var rawValues:               [Glucose] = []
    var rawTrend:                [Glucose] = []
    var factoryValues:           [Glucose] = []
    var factoryTrend:            [Glucose] = []
    var storedValues:            [Glucose] = []
    var nightscoutValues:        [Glucose] = []
    var insulinDeliveries:       [InsulinDelivery] = []
    var consumedCarbohydrates:   [Carbohydrates] = []
}
