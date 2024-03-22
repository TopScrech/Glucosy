import SwiftUI

func showReminder(_ date1: Date, _ date2: Date) -> Bool {
    let seconds1 = date1.timeIntervalSinceReferenceDate
    let seconds2 = date2.timeIntervalSinceReferenceDate
    
    let difference = seconds1 - seconds2
    
    if  difference > 7200 {
        return true
    } else {
        return false
    }
}
