import Foundation

extension Graph {
    var last24Glucose: [Glucose] {
        history.glucose.filter { glucose in
            glucose.date > yesterday
        }
    }
    
    var last24Carbs: [Carbohydrates] {
        combineCarbsObjectsIfNeeded(
            history.carbs.filter { carbs in
                carbs.date > yesterday
            }
        )
    }
    
    var last24Insulin: [InsulinDelivery] {
        history.insulin.filter { insulin in
            insulin.date > yesterday
        }
    }
    
    var maxGlucose: Glucose? {
        last24Glucose.max(by: {
            $0.value < $1.value
        })
    }
    
    var minGlucose: Glucose? {
        last24Glucose.min(by: {
            $0.value < $1.value
        })
    }
}
