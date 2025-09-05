import SwiftUI

final class ValueStore: ObservableObject {
#if !os(visionOS)
    @AppStorage("appearance") var appearance: ColorTheme = .system
#endif
    
    @AppStorage("debug_mode") var debugMode = false
}
