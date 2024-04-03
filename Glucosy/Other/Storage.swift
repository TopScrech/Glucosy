import SwiftUI

final class Storage: ObservableObject {
    @AppStorage("debug_mode") var debugMode = false
    
    @AppStorage("started_warming_up") var startedWarmingUpTime = 0.0
    var startedWarmingUpDate: Date {
        set {
            startedWarmingUpTime = newValue.timeIntervalSinceReferenceDate
        }
        
        get {
            Date(timeIntervalSinceReferenceDate: startedWarmingUpTime)
        }
    }
}
