import Foundation

extension MainDelegate {
    func saveNewData(_ sensor: Sensor?, currentGlucose: Int) {
        guard let sensor else {
            return
        }
        
        if history.values.count > 0 || history.factoryValues.count > 0 || currentGlucose > 0 {
            var entries = [Glucose]()
            
            if history.values.count > 0 {
                entries += history.values
            } else {
                entries += history.factoryValues
            }
            
            entries += history.factoryTrend.dropFirst() + [Glucose(currentGlucose, date: sensor.lastReadingDate)]
            entries = entries.filter {
                $0.value > 0 && $0.id > -1
            }
            
            // TODO
            let newEntries = entries.filter {
                $0.date > healthKit?.lastDate ?? Calendar.current.date(byAdding: .hour, value: -8, to: Date())!
            }
            
            if newEntries.count > 0 {
                healthKit?.writeGlucose(newEntries)
                healthKit?.readGlucose()
            }
            
            nightscout?.read { [self] values in
                let newEntries = values.count > 0 ? entries.filter {
                    $0.date > values[0].date
                } : entries
                
                if newEntries.count > 0 {
                    nightscout?.post(entries: newEntries) { [self] data, response, error in
                        nightscout?.read()
                    }
                }
            }
        }
    }
}
