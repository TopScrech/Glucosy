import SwiftUI

struct CarbsList: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    
    private let carbs: [Carbohydrates]
    
    init(_ carbs: [Carbohydrates]) {
        self.carbs = carbs
    }
    
    var body: some View {
        List {
            ForEach(history.carbs, id: \.self) { carbs in
                CarbohydratesCard(carbs)
            }
            .onDelete(perform: deleteCarbs)
        }
    }
    
    private func deleteCarbs(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.carbs[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.carbs.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    CarbsList([])
}
