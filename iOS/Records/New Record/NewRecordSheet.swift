import ScrechKit

struct NewRecordSheet: View {
    private let recordType: RecordType
    private let insulinType: InsulinType?
    
    init(_ recordType: RecordType, insulinType: InsulinType? = nil) {
        self.recordType = recordType
        self.insulinType = insulinType
    }
    
    var body: some View {
        NavigationStack {
            switch recordType {
            case .insulin:
                NewRecordInsulin(insulinType: insulinType ?? .bolus)
                
            case .glucose:
                NewRecordGlucose()
                
            case .carbs:
                NewRecordCarbs()
                
            case .weight:
                LogWeightSheet()
                
            case .bmi:
                LogBMISheet()
            }
        }
    }
}

#Preview {
    NewRecordSheet(.insulin)
        .darkSchemePreferred()
        .environment(HealthKit())
}
