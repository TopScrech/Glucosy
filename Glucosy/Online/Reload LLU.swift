import Foundation

extension OnlineView {
    func reloadLLU() async {
        if let libreLinkUp = await app.main?.libreLinkUp {
            var dataString = ""
            var retries = 0
        loop: repeat {
            do {
                if settings.libreLinkUpPatientId.isEmpty ||
                    settings.libreLinkUpToken.isEmpty ||
                    settings.libreLinkUpTokenExpirationDate < Date() ||
                    retries == 1 {
                    
                    do {
                        try await libreLinkUp.login()
                    } catch {
                        libreLinkUpResponse = error.localizedDescription.capitalized
                    }
                }
                
                if !(settings.libreLinkUpPatientId.isEmpty ||
                     settings.libreLinkUpToken.isEmpty) {
                    let (data, _, graphHistory, logbookData, logbookHistory, _) = try await libreLinkUp.getPatientGraph()
                    dataString = (data as! Data).string
                    libreLinkUpResponse = dataString + (logbookData as! Data).string
                    // TODO: just merge with newer values
                    libreLinkUpHistory = graphHistory.reversed()
                    libreLinkUpLogbookHistory = logbookHistory
                    
                    if graphHistory.count > 0 {
                        DispatchQueue.main.async {
                            settings.lastOnlineDate = Date()
                            let lastMeasurement = libreLinkUpHistory[0]
                            app.lastReadingDate = lastMeasurement.glucose.date
                            app.sensor?.lastReadingDate = app.lastReadingDate
                            app.currentGlucose = lastMeasurement.glucose.value
                            // TODO: keep the raw values filling the gaps with -1 values
                            history.rawValues = []
                            history.factoryValues = libreLinkUpHistory.dropFirst().map(\.glucose) // TEST
                            var trend = history.factoryTrend
                            
                            if trend.isEmpty || lastMeasurement.id > trend[0].id {
                                trend.insert(lastMeasurement.glucose, at: 0)
                            }
                            
                            // keep only the latest 22 minutes considering the 17-minute latency of the historic values update
                            trend = trend.filter {
                                lastMeasurement.id - $0.id < 22
                            }
                            
                            history.factoryTrend = trend
                            // TODO: merge and update sensor history / trend
                            app.main.didParseSensor(app.sensor)
                        }
                    }
                    
                    if dataString != "{\"message\":\"MissingCachedUser\"}\n" {
                        break loop
                    }
                    
                    retries += 1
                }
            } catch {
                libreLinkUpResponse = error.localizedDescription.capitalized
            }
        } while retries == 1
        }
    }
}
