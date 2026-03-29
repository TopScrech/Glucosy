import SwiftUI

struct ReaderActionsSection: View {
    @Bindable var vm: PenReaderVM

    var body: some View {
        Section("Actions") {
            Toggle("Receive Full History", isOn: $vm.readerOptions.receivesFullHistory)
                .disabled(vm.isWorking)

            Button("Load Sample Trace", systemImage: "doc.text.magnifyingglass", action: vm.loadSampleTrace)
                .disabled(vm.isWorking)
        }
    }
}
