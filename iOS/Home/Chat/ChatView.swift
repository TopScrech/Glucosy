import ScrechKit
import ChitChat

@available(iOS 26, *)
struct ChatView: View {
    @State private var vm = ChatVM()
    @State private var alertTokenWindowUsage = false
    @State private var carbDraft: ChatCarbDraft?
    @State private var insulinDraft: ChatInsulinDraft?
    @State private var dietaryEnergyDraft: ChatDietaryEnergyDraft?
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if vm.messages.isEmpty {
                    ContentUnavailableView(
                        "Estimate food or log a record",
                        systemImage: "siri",
                        description: Text("Estimate carbs or calories in food, or ask to log carbs, insulin, or dietary calories you provide. Review and save each entry using the add buttons")
                    )
                    .symbolRenderingMode(.multicolor)
                } else {
                    ForEach(vm.messages) {
                        ChatMessageBubble(message: $0) {
                            carbDraft = $0
                        } onLogInsulin: {
                            insulinDraft = $0
                        } onLogDietaryEnergy: {
                            dietaryEnergyDraft = $0
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
        .sheet(item: $insulinDraft) { draft in
            NavigationStack {
                NewRecordInsulin(insulinType: draft.type, initialAmount: draft.units)
            }
        }
        .sheet(item: $dietaryEnergyDraft) { draft in
            NavigationStack {
                LogDietaryEnergyView(initialAmount: draft.kilocalories)
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
