import SwiftUI

struct ReaderStatusSection: View {
    let viewModel: PenReaderVM

    var body: some View {
        Section("Status") {
            LabeledContent("State") {
                Text(viewModel.statusTitle)
                    .bold()
            }

            Text(viewModel.statusMessage)
                .foregroundStyle(.secondary)
        }
    }
}
