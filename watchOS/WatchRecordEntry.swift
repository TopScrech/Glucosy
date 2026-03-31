import SwiftUI

struct WatchRecordEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let systemImage: String
    let tint: Color
    let valueText: String
    let unitText: String
    let detailText: String?
}
