enum GlycemicAlarm: Int, CustomStringConvertible, CaseIterable, Codable {
    case unknown              = -1
    case notDetermined        = 0
    case lowGlucose           = 1
    case projectedLowGlucose  = 2
    case glucoseOK            = 3
    case projectedHighGlucose = 4
    case highGlucose          = 5
    
    var description: String {
        switch self {
        case .notDetermined:        "NOT_DETERMINED"
        case .lowGlucose:           "LOW_GLUCOSE"
        case .projectedLowGlucose:  "PROJECTED_LOW_GLUCOSE"
        case .glucoseOK:            "GLUCOSE_OK"
        case .projectedHighGlucose: "PROJECTED_HIGH_GLUCOSE"
        case .highGlucose:          "HIGH_GLUCOSE"
        default:                    ""
        }
    }
    
    init(string: String) {
        self = Self.allCases.first { $0.description == string } ?? .unknown
    }
    
    var shortDescription: String {
        switch self {
        case .lowGlucose:           "LOW"
        case .projectedLowGlucose:  "GOING LOW"
        case .glucoseOK:            "OK"
        case .projectedHighGlucose: "GOING HIGH"
        case .highGlucose:          "HIGH"
        default:                    ""
        }
    }
}
