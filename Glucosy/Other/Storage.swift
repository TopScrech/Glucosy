import SwiftUI

final class Storage: ObservableObject {
    @AppStorage("debug_mode") var debugMode = false
}
