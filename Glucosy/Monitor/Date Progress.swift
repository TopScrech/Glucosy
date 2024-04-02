import SwiftUI

struct RemainingTime: View {
    private let startDate: Date
    private let endDate: Date
    
    init(_ startDate: Date, _ endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    private var progress: Float {
        let totalInterval = endDate.timeIntervalSince(startDate)
        let currentInterval = Date().timeIntervalSince(startDate)
        
        return totalInterval > 0 ? Float(currentInterval / totalInterval) : 0
    }
    
    private var timeLeft: String {
        let remainingSeconds = Int(endDate.timeIntervalSince(Date()))
        
        if remainingSeconds <= 0 {
            return "Time's up!"
        } else {
            return stringFromTimeInterval(interval: remainingSeconds)
        }
    }
    
    private func stringFromTimeInterval(interval: Int) -> String {
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        let minutes = (interval % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    var body: some View {
        VStack {
            Text(timeLeft)
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
        }
    }
}

#Preview {
    RemainingTime(Date().addingTimeInterval(-100_000), Date().addingTimeInterval(100_000))
}

#Preview {
    RemainingTime(Date().addingTimeInterval(-100_00), Date().addingTimeInterval(100_00))
}
