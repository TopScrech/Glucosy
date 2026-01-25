import SwiftUI

struct TodayLatestSectionView<Content: View>: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest")
                .title3(.semibold, design: .rounded)
            
            VStack(spacing: 12) {
                content
            }
        }
    }
}

#Preview {
    TodayLatestSectionView {
        TodayLatestRowView(
            title: "Blood Glucose",
            value: "118",
            unit: "mg/dL",
            date: Date(),
            icon: "drop",
            color: .red
        )
    }
    .padding()
    .darkSchemePreferred()
}
