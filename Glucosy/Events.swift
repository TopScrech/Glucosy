import EventKit

class EventKit: Logging {
    var main: MainDelegate!
    var store = EKEventStore()
    var calendarTitles = [String]()
    
    init(main: MainDelegate) {
        self.main = main
    }
    
    // https://github.com/JohanDegraeve/xdripswift/blob/master/xdrip/Managers/Watch/WatchManager.swift
    
    func sync(handler: ((EKCalendar?) -> Void)? = nil) {
        store.requestFullAccessToEvents { [self] granted, error  in
            guard granted else {
                debugLog("EventKit: full access not granted, error: \(error?.localizedDescription ?? "nil"), full access to calendar events authorization status: \(["notDetermined", "restricted", "denied", "fullAccess", "writeOnly"][EKEventStore.authorizationStatus(for: .event).rawValue])")
                return
            }
            
            guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
                log("EventKit: full access to calendar events not authorized")
                return
            }
            
            calendarTitles = store.calendars(for: .event)
                .filter(\.allowsContentModifications)
                .map(\.title)
            
            guard settings.calendarTitle != "" else {
                return
            }
            
            var calendar: EKCalendar?
            
            for storeCalendar in store.calendars(for: .event) {
                if storeCalendar.title == settings.calendarTitle {
                    calendar = storeCalendar
                    break
                }
            }
            
            if calendar == nil {
                calendar = store.defaultCalendarForNewEvents
            }
            
            let predicate = store.predicateForEvents(withStart: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, end: Date(), calendars: [calendar!])  // Date.distantPast doesn't work
            for event in store.events(matching: predicate) {
                if let notes = event.notes {
                    if notes.contains("Created by Glucosy") {
                        do {
                            try store.remove(event, span: .thisEvent)
                        } catch {
                            debugLog("EventKit: error while deleting calendar events created by Glucosy: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            let currentGlucose = app.currentGlucose
            var title = currentGlucose > 0 ? "\(currentGlucose.units)" : "---"
            
            if currentGlucose != 0 {
                title += "  \(settings.displayingMillimoles ? GlucoseUnit.mmoll : GlucoseUnit.mgdl)"
                
                let alarm = app.glycemicAlarm
                
                if alarm != .unknown {
                    title += "  \(alarm.shortDescription)"
                } else {
                    if currentGlucose > Int(settings.alarmHigh) {
                        title += "  HIGH"
                    }
                    
                    if currentGlucose < Int(settings.alarmLow) {
                        title += "  LOW"
                    }
                }
                
                let trendArrow = app.trendArrow
                
                if trendArrow != .unknown {
                    title += "  \(trendArrow.symbol)"
                }
                
                if app.trendDeltaMinutes > 0 {
                    title += "\n"
                    title += "\(app.trendDelta > 0 ? "+" : app.trendDelta < 0 ? "-" : "")\(app.trendDelta == 0 ? "→" : abs(app.trendDelta).units)" + " over " + "\(app.trendDeltaMinutes)" + " min"
                } else {
                    title += "\n Computing trend"
                }
                
                let snoozed = settings.lastAlarmDate.timeIntervalSinceNow >= -Double(settings.alarmSnoozeInterval * 60) && settings.disabledNotifications
                
                let event = EKEvent(eventStore: store)
                event.title = title
                event.notes = "Created by Glucosy"
                event.startDate = Date()
                event.endDate = Date(timeIntervalSinceNow: TimeInterval(60 * max(settings.readingInterval, settings.onlineInterval, snoozed ? settings.alarmSnoozeInterval : 0) + 5))
                event.calendar = calendar
                
                if !snoozed && settings.calendarAlarmIsOn {
                    if currentGlucose > 0 && (currentGlucose > Int(settings.alarmHigh) || currentGlucose < Int(settings.alarmLow)) {
                        let alarm = EKAlarm(relativeOffset: 1)
                        event.addAlarm(alarm)
                    }
                }
                
                do {
                    try store.save(event, span: .thisEvent)
                } catch {
                    log("EventKit: error while saving event: \(error.localizedDescription)")
                }
                
                handler?(calendar)
            }
        }
    }
}
