import Foundation

extension Graph {
    // Combine Carbs objects and calculate the average time
    func processAndCombineCarbs(tempCarbs: [Carbohydrates]) -> Carbohydrates {
        let totalAmount = tempCarbs.reduce(0) { $0 + $1.value }
        
        let averageDate = tempCarbs.map {
            $0.date.timeIntervalSince1970
        }.reduce(0, +) / Double(tempCarbs.count)
        
        let combinedCarbs = Carbohydrates(value: totalAmount, date: Date(timeIntervalSince1970: averageDate))
        
        return combinedCarbs
    }
    
    func combineCarbsObjectsIfNeeded(_ carbs: [Carbohydrates]) -> [Carbohydrates] {
        let sortedCarbs = carbs.sorted {
            $0.date < $1.date
        }
        
        var resultArray: [Carbohydrates] = []
        var tempArray:   [Carbohydrates] = []
        
        for carbs in sortedCarbs {
            
            if tempArray.isEmpty {
                tempArray.append(carbs)
            } else {
                if let lastCarbs = tempArray.last {
                    let interval = carbs.date.timeIntervalSince(lastCarbs.date)
                    
                    if interval <= 1800 { /// 30 min
                        tempArray.append(carbs)
                    } else {
                        let combinedCarbs = processAndCombineCarbs(tempCarbs: tempArray)
                        resultArray.append(combinedCarbs)
                        
                        // Clear tempArray and add current carbs for next comparison
                        tempArray = [carbs]
                    }
                }
            }
        }
        
        // Make sure to process any remaining carbs in tempArray after the loop
        if !tempArray.isEmpty {
            let combinedCarbs = processAndCombineCarbs(tempCarbs: tempArray)
            
            resultArray.append(combinedCarbs)
        }
        
        return resultArray
    }
}
