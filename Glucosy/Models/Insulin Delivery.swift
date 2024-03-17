import Foundation

struct InsulinDelivery: Hashable {
    let amount: Int
    let type: InsulinType
    let date: Date
}
