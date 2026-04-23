import ScrechKit
import ChitChat

@available(iOS 26, *)
struct FoundationModelChatView: View {
    @State private var vm = ChatVM()
    @State private var alertTokenWindowUsage = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if vm.messages.isEmpty {
                    ContentUnavailableView(
                        "Estimate carbs",
                        systemImage: "apple.intelligence",
                        description: Text("The assistant can only estimate the carbohydrate content of a product. Use this as a reference only, not as medical advice")
                    )
                    .symbolRenderingMode(.multicolor)
                } else {
                    ForEach(vm.messages) {
                        ChatMessageBubble($0)
                    }
                }
            }
            .scenePadding()
            .padding(.bottom, 40)
        }
        .navigationTitle("Assistant")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            vm.printContextSize()
        }
        .alert("Token Window Usage", isPresented: $alertTokenWindowUsage) {
            
        } message: {
            Text("This indicator shows the amount of used tokens")
        }
        .overlay(alignment: .bottom) {
            ChatComposerView()
                .environment(vm)
        }
        .toolbar {
            if #available(iOS 26.4, *) {
                ToolbarItem(placement: .topBarLeading) {
                    TokenUsageGauge(value: vm.tokenUsage) {
                        alertTokenWindowUsage = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NewChatButton(disabled: vm.isResponding || vm.messages.isEmpty, action: vm.startNewChat)
            }
        }
    }
}
