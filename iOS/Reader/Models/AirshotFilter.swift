import Foundation

enum AirshotFilter: String, CaseIterable, Hashable, Identifiable {
    case disabled, upTo1Unit, upTo2Units, upTo3Units

    var id: Self { self }

    var title: String {
        switch self {
        case .disabled:
            "Disabled"
        case .upTo1Unit:
            "0 to 1 units"
        case .upTo2Units:
            "0 to 2 units"
        case .upTo3Units:
            "0 to 3 units"
        }
    }

    var maxUnits: Double? {
        switch self {
        case .disabled:
            nil
        case .upTo1Unit:
            1
        case .upTo2Units:
            2
        case .upTo3Units:
            3
        }
    }
}
