import Foundation

enum GlucoseUnit: String, CaseIterable, Identifiable {
    case mmolL, mgdL
    
    private static let milligramsPerDeciliterPerMillimolePerLiter = 18.0182
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .mmolL: String(localized: "mmol/L")
        case .mgdL: String(localized: "mg/dL")
        }
    }
    
    func displayValue(fromMilligramsPerDeciliter value: Double) -> Double {
        switch self {
        case .mmolL:
            value / Self.milligramsPerDeciliterPerMillimolePerLiter
            
        case .mgdL:
            value
        }
    }
    
    func milligramsPerDeciliter(fromDisplayValue value: Double) -> Double {
        switch self {
        case .mmolL:
            value * Self.milligramsPerDeciliterPerMillimolePerLiter
            
        case .mgdL:
            value
        }
    }
    
    func formattedValue(fromMilligramsPerDeciliter value: Double) -> String {
        let convertedValue = displayValue(fromMilligramsPerDeciliter: value)
        
        switch self {
        case .mmolL:
            return convertedValue.formatted(.number.precision(.fractionLength(0 ... 1)))
            
        case .mgdL:
            return convertedValue.formatted(.number.precision(.fractionLength(0)))
        }
    }
}

extension Glucose {
    func formattedValue(in unit: GlucoseUnit) -> String {
        unit.formattedValue(fromMilligramsPerDeciliter: value)
    }
}
