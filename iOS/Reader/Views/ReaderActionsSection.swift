import SwiftUI

struct ReaderActionsSection: View {
    @Environment(PenReaderVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Section("Actions") {
            Toggle("Receive Full History", isOn: $vm.readerOptions.receivesFullHistory)
                .disabled(vm.isWorking)
            
            Button("Load Sample Trace", systemImage: "doc.text.magnifyingglass", action: vm.loadSampleTrace)
                .disabled(vm.isWorking)
        }
    }
}
