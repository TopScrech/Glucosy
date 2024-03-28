import ScrechKit

struct StandartToolbar: ViewModifier {
    @Environment(AppState.self) private var app: AppState
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton("note.text") {
                        app.sheetNewRecord = true
                    }
                    .tint(.yellow)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SFButton("sensor.tag.radiowaves.forward.fill") {
                        app.main.nfc.startSession()
                    }
                    .tint(.white)
                    .symbolEffect(.variableColor.reversing)
                }
            }
    }
}

extension View {
    func standartToolbar() -> some View {
        self
            .modifier(StandartToolbar())
    }
}
