import SwiftUI

struct ReaderStatusSection: View {
    @Environment(PenReaderVM.self) private var vm
    
    var body: some View {
        Section("Status") {
            LabeledContent("State") {
                Text(vm.statusTitle)
                    .bold()
            }
            
            Text(vm.statusMessage)
                .secondary()
        }
    }
}
