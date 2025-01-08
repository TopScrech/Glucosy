import SwiftUI

final class ValueStorage: ObservableObject {
    @AppStorage("debug_mode") var debugMode = false
}
