import SwiftUI

struct TodayHeaderView: View {
    let date: Date
    let lastUpdated: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day())
                .title2(.semibold, design: .rounded)
            
            if let lastUpdated {
                Text("Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                    .caption()
                    .secondary()
            } else {
                Text("No updates yet")
                    .caption()
                    .secondary()
            }
        }
    }
}

#Preview {
    TodayHeaderView(date: Date(), lastUpdated: Date())
        .darkSchemePreferred()
}
