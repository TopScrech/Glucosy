import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatLogInsulinAction {
    @Guide(description: "The exact positive insulin dose in units explicitly supplied by the user for logging, never a calculated or recommended dose")
    var units: Double

    @Guide(description: "The basal or bolus type explicitly supplied by the user")
    var type: ChatInsulinType
}
