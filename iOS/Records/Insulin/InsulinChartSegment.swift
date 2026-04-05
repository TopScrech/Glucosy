import Foundation
import SwiftUI

struct InsulinChartSegment: Identifiable {
    let date: Date
    let type: InsulinType
    let value: Double
    let lowerBound: Double
    let upperBound: Double
    
    var id: String {
        "\(date.timeIntervalSinceReferenceDate)-\(type.rawValue)"
    }
    
    var title: String {
        type.title
    }
    
    var color: Color {
        switch type {
        case .basal:
            .gray
            
        case .bolus:
            .blue
        }
    }
}
