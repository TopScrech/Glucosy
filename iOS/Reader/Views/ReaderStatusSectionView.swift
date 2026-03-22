import SwiftUI

struct ReaderStatusSectionView: View {
    let viewModel: PenReaderViewModel

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
