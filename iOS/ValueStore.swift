import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

final class ValueStore: ObservableObject {
#if canImport(Appearance)
    @AppStorage("appearance") var appearance: Appearance = .system
#endif
    
    @AppStorage("airshot_filter") var airshotFilterRawValue = "disabled"
    @AppStorage("debug_mode") var debugMode = false
    @AppStorage("selected_tab") var selectedTab = 0
}

#if os(iOS)
extension ValueStore {
    var airshotFilter: AirshotFilter {
        get { AirshotFilter(rawValue: airshotFilterRawValue) ?? .disabled }
        set { airshotFilterRawValue = newValue.rawValue }
    }
    
    func normalizeSelectedTab() {
        switch selectedTab {
        case 0 ... 2:
            return
        case 3:
            selectedTab = 2
        default:
            selectedTab = 0
        }
    }
}
#endif
