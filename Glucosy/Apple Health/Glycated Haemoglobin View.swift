import SwiftUI

func calculateAverage(_ glucoseMeasurements: [Glucose]) -> Double {
    //    let glucoseMeasurements: [Glucose] = [/* Your array of Glucose objects here */]
    
    // Group glucose measurements by day
    let groupedByDay = Dictionary(grouping: glucoseMeasurements) { (glucose) -> Date in
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: glucose.date)
        
        return calendar.date(from: components)!
    }
    
    // Calculate daily averages
    let dailyAverages = groupedByDay.map { (date, measurements) -> Double in
        let totalValue = measurements.reduce(0) {
            $0 + (Double($1.value))
        }
        
        return totalValue / Double(measurements.count)
    }
    
    // Calculate overall average of daily averages
    let overallAverage = dailyAverages.reduce(0, +) / Double(dailyAverages.count)
    
    return overallAverage
}

struct GlycatedHaemoglobinView: View {
    private let data: [Glucose]
    
    init(_ data: [Glucose]) {
        self.data = data
    }
    
    private var averageGlucose: Double {
        calculateAverage(data)
    }
    
    private var hb1acPercent: Double {
        (calculateAverage(data) + 46.7) / 28.7
    }
    
    private var hb1acPercentage: String {
        String(format: "%.1f", hb1acPercent)
    }
    
    private var hb1acValue: String {
        String(format: "%.0f", hb1acPercent * 10.929 - 23.5)
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Average Glucose")
                
                Spacer()
                
                Text(averageGlucose.units)
                    .bold()
            }
            
            HStack {
                Text("Estimated HbA1c")
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(hb1acPercentage)%")
                        .bold()
                    
                    Text("\(hb1acValue) mmol/mol")
                        .foregroundStyle(.secondary)
                        .footnote()
                }
            }
        }
    }
}

#Preview {
    List {
        GlycatedHaemoglobinView(History.test.glucose)
    }
}
