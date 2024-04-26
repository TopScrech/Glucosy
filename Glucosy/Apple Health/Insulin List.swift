import SwiftUI

struct InsulinList: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    
    var body: some View {
        List {
            ForEach(history.insulin, id: \.self) { insulin in
                InsulinCard(insulin)
            }
            .onDelete(perform: deleteInsulin)
        }
    }
    
    private func deleteInsulin(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.insulin[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.insulin.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    InsulinList()
}
