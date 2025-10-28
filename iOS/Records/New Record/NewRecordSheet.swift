import SwiftUI

struct NewRecordSheet: View {
    private let recorType: RecordType
    
    init(_ recorType: RecordType) {
        self.recorType = recorType
    }
    
    var body: some View {
        NavigationView {
            switch recorType {
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
}
