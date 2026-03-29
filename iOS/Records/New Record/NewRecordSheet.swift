import SwiftUI

struct NewRecordSheet: View {
    private let recordType: RecordType
    
    init(_ recordType: RecordType) {
        self.recordType = recordType
    }
    
    var body: some View {
        NavigationStack {
            switch recordType {
            case .insulin:
                NewRecordInsulin()
                
            case .glucose:
                NewRecordGlucose()
                
            case .carbs:
                NewRecordCarbs()
            }
        }
    }
}

#Preview {
    NewRecordSheet(.insulin)
        .darkSchemePreferred()
        .environment(HealthKit())
}
