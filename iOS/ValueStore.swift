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
}

#if os(iOS)
extension ValueStore {
    var airshotFilter: AirshotFilter {
        get { AirshotFilter(rawValue: airshotFilterRawValue) ?? .disabled }
        set { airshotFilterRawValue = newValue.rawValue }
    }
}
#endif
