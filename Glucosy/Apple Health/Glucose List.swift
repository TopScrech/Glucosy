import SwiftUI

struct GlucoseList: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    
    var body: some View {
        List {
            ForEach(history.glucose, id: \.self) { glucose in
                GlucoseCard(glucose)
            }
            .onDelete(perform: deleteGlucose)
        }
    }
    
    private func deleteGlucose(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.glucose[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.glucose.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting glucose: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    GlucoseList()
        .glucosyPreview(.healthKit)
}
