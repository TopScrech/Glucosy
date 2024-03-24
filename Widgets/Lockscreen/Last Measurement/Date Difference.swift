import SwiftUI

func showReminder(_ date1: Date, _ date2: Date) -> Int? {
    let seconds1 = date1.timeIntervalSinceReferenceDate
    let seconds2 = date2.timeIntervalSinceReferenceDate
    
    let difference = seconds1 - seconds2
    let roundedDifference = (difference / 60 / 60).rounded()
    
    if  difference > 7200 {
        return Int(roundedDifference)
    } else {
        return nil
    }
}
