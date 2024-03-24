enum UserLevel: Int, CaseIterable, Comparable {
    case basic = 0
    case devel = 1
    case test  = 2
    
    static func < (lhs: UserLevel, rhs: UserLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
