import SwiftUI

struct NewRecordSheet: View {
    private let recorType: RecorType
    
    init(_ recorType: RecorType) {
        self.recorType = recorType
    }
    
    var body: some View {
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

#Preview {
    NewRecordSheet(.insulin)
}
