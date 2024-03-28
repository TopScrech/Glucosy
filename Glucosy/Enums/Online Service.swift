enum OnlineService: String, CaseIterable {
    case nightscout = "Nightscout"
    case libreLinkUp = "LibreLinkUp"
    
    mutating func toggle() {
        self = self == .nightscout ? .libreLinkUp : .nightscout
    }
}
