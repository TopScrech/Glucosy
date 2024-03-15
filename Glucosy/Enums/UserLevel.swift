public enum UserLevel: Int, CaseIterable, Comparable {
    case basic = 0
    case devel = 1
    case test  = 2
    
    public static func < (lhs: UserLevel, rhs: UserLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
