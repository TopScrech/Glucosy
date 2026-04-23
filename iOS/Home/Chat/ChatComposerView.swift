import ScrechKit

@available(iOS 26, *)
struct ChatComposerView: View {
    @Environment(ChatVM.self) private var vm
    @Environment(HealthKit.self) private var healthKit
    @EnvironmentObject private var store: ValueStore
    
    @FocusState private var isFocused
    
    var body: some View {
        @Bindable var vm = vm
        
        HStack {
            TextField("Type here...", text: $vm.prompt)
                .onSubmit(sendPrompt)
                .padding(.horizontal)
                .frame(height: 35)
#if !os(visionOS)
                .glassEffect()
#endif
                .focused($isFocused)
                .submitLabel(.send)
                .disabled(vm.isResponding)
            
            Button("Send", systemImage: "paperplane", action: sendPrompt)
                .labelStyle(.iconOnly)
                .frame(35)
#if !os(visionOS)
                .glassEffect()
#endif
                .disabled(vm.isResponding || vm.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .task {
            isFocused = true
        }
    }
    
    private func sendPrompt() {
        vm.refreshContext(using: healthKit, glucoseUnit: store.glucoseUnit)
        
        Task {
            await vm.sendPrompt()
        }
    }
}
