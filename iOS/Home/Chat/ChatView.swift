import ScrechKit
import ChitChat

@available(iOS 26, *)
struct ChatView: View {
    @State private var vm = ChatVM()
    @State private var alertTokenWindowUsage = false
    @State private var carbDraft: ChatCarbDraft?
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if vm.messages.isEmpty {
                    ContentUnavailableView(
                        "Estimate carbs",
                        systemImage: "siri",
                        description: Text("The assistant can only estimate the carbohydrate content of a product. Use this as a reference only, not as medical advice")
                    )
                    .symbolRenderingMode(.multicolor)
                } else {
                    ForEach(vm.messages) {
                        ChatMessageBubble(message: $0) {
                            carbDraft = $0
                        } onStartNewChat: {
                            vm.startNewChat()
                        }
                    }
                }
            }
            .scenePadding()
        }
        .navigationTitle("Assistant")
        .toolbarTitleDisplayMode(.inline)
        .animation(.default, value: vm.messages.count)
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await vm.printContextSize()
        }
        .alert("Token Window Usage", isPresented: $alertTokenWindowUsage) {
            
        } message: {
            Text("This indicator shows the amount of used tokens")
        }
        .sheet(item: $carbDraft) { carbDraft in
            NavigationStack {
                NewRecordCarbs(initialAmount: carbDraft.carbsAmount)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputView()
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
                NewChatButton(disabled: vm.isResponding || vm.isLoadingImages || vm.messages.isEmpty, action: vm.startNewChat)
            }
        }
    }
}
