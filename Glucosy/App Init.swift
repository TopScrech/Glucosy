import SwiftUI
import SwiftData

extension GlucosyApp {
    init() {
        let schema = Schema([
            Pen.self
        ])
        
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create model container")
        }
    }
}
