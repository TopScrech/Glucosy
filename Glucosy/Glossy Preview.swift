import SwiftUI

extension View {
    func glucosyPreview(_ tab: Tab = .monitor) -> some View {
        self
            .modifier(GlucosyPreview(tab))
    }
}

struct GlucosyPreview: ViewModifier {
    private let tab: Tab
    
    init(_ tab: Tab) {
        self.tab = tab
    }
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.dark)
            .environment(AppState.test(tab: tab))
            .environment(Log())
            .environment(History.test)
            .environment(Settings())
    }
}
