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
    @AppStorage("glucose_unit") var glucoseUnitRawValue = "mmolL"
}

#if os(iOS)
extension ValueStore {
    var airshotFilter: AirshotFilter {
        get { AirshotFilter(rawValue: airshotFilterRawValue) ?? .disabled }
        set { airshotFilterRawValue = newValue.rawValue }
    }

    var glucoseUnit: GlucoseUnit {
        get { GlucoseUnit(rawValue: glucoseUnitRawValue) ?? .mmolL }
        set { glucoseUnitRawValue = newValue.rawValue }
    }
}
#endif
