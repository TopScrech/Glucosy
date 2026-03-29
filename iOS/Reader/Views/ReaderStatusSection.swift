import SwiftUI

struct ReaderStatusSection: View {
    let vm: PenReaderVM
    
    var body: some View {
        Section("Status") {
            LabeledContent("State") {
                Text(vm.statusTitle)
                    .bold()
            }
            
            Text(vm.statusMessage)
                .foregroundStyle(.secondary)
        }
    }
}
