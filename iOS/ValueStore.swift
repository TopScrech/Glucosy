import SwiftUI

final class ValueStore: ObservableObject {
    @AppStorage("debug_mode") var debugMode = false
}
