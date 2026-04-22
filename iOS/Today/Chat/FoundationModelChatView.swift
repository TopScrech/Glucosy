#if os(iOS)
import ScrechKit

@available(iOS 26, *)
struct FoundationModelChatView: View {
    @Environment(HealthKit.self) private var healthKit
    @EnvironmentObject private var store: ValueStore

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
                        ChatMessageRowView($0)
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
            vm.refreshContext(using: healthKit, glucoseUnit: store.glucoseUnit)
        }
        .onChange(of: store.glucoseUnit) { _, newValue in
            vm.refreshContext(using: healthKit, glucoseUnit: newValue)
        }
        .alert("Token Window Usage", isPresented: $alertTokenWindowUsage) {

        } message: {
            Text("This indicator shows the amount of used tokens")
        }
        .overlay(alignment: .bottom) {
            ChatComposerView()
                .environment(vm)
                .environment(healthKit)
        }
        .toolbar {
            if #available(iOS 26.4, *) {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        alertTokenWindowUsage = true
                    } label: {
                        Gauge(value: vm.tokenUsage) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .scaleEffect(0.5)
                            .frame(30)
                            .tint(.green)
                            .animation(.default, value: vm.tokenUsage)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("New Chat", systemImage: "square.and.pencil", action: vm.startNewChat)
                    .disabled(vm.isResponding || vm.messages.isEmpty)
            }
        }
    }
}
#endif
