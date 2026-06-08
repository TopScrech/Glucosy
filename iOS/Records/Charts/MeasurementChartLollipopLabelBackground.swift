import SwiftUI

struct MeasurementChartLollipopLabelBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, visionOS 26, *) {
            content
                .background(.thinMaterial, in: .rect(cornerRadius: 8))
                .clipShape(.rect(cornerRadius: 8))
                .glassEffect(.regular, in: .rect(cornerRadius: 8))
        } else {
            content
                .background(.regularMaterial, in: .rect(cornerRadius: 8))
        }
    }
}
