import Foundation

@Observable
final class AppState {
    var device:      Device!
    var transmitter: Transmitter!
    var sensor:      Sensor!
    var main:        MainDelegate!
    
    let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var currentGlucose = 0
    var lastReadingDate: Date = .distantPast
    var glycemicAlarm: GlycemicAlarm = .unknown
    var trendArrow:    TrendArrow    = .unknown
    var trendDelta = 0
    var trendDeltaMinutes = 0
    
    var deviceState = ""
    var lastConnectionDate: Date = .distantPast
    var status = "Welcome to Glucosy!"
    
    // Hacks
    var dialogRePair = false
    var dialogUnlock = false
    var dialogReset = false
    var dialogProlong = false
    var dialogActivate = false
    
    // Console
    var filterText = ""
    var showConsoleFilter = false
    
    var alertJSConfirm = false
    var jsConfirmAlertMessage = ""
    // var jstAlertReturn = ""
    
    var alertNfc = false
    var alertActivation = false
    var sheetNewRecord = false
}
