import Foundation

nonisolated struct HealthRefreshState {
    var recent: Date?
    var history: Date?

    func isFresh(fullHistory: Bool, now: Date = .now) -> Bool {
        guard let date = fullHistory ? history : recent else { return false }
        let age = now.timeIntervalSince(date)
        return age >= 0 && age < 60
    }

    mutating func recordSuccess(fullHistory: Bool, at date: Date = .now) {
        recent = date
        if fullHistory { history = date }
    }
}
