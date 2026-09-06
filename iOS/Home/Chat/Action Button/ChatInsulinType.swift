import FoundationModels

@available(iOS 26, *)
@Generable
enum ChatInsulinType {
    case bolus, basal

    var insulinType: InsulinType {
        switch self {
        case .bolus: .bolus
        case .basal: .basal
        }
    }
}
