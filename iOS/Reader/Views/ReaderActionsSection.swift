import SwiftUI

struct ReaderActionsSection: View {
    @Bindable var viewModel: PenReaderVM

    var body: some View {
        Section("Actions") {
            Toggle("Receive Full History", isOn: $viewModel.readerOptions.receivesFullHistory)
                .disabled(viewModel.isWorking)

            Button("Scan Pen", systemImage: "wave.3.right", action: viewModel.startScan)
                .disabled(viewModel.isWorking)

            Button("Load Sample Trace", systemImage: "doc.text.magnifyingglass", action: viewModel.loadSampleTrace)
                .disabled(viewModel.isWorking)
        }
    }
}
