import ScrechKit
import PhotosUI

@available(iOS 26, *)
struct ChatInputView: View {
    @Environment(ChatVM.self) private var vm
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showsPhotoPicker = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(alignment: .leading) {
            if !vm.attachments.isEmpty {
                ChatImageStrip(attachments: vm.attachments) { id in
                    vm.attachments.removeAll { $0.id == id }
                }
            }
            
            TextField("Ask about food or log a record", text: $vm.prompt, axis: .vertical)
                .lineLimit(1...6)
                .focused($isFocused)
                .padding(.bottom)
            
            if let error = vm.attachmentError {
                Text(error)
                    .caption()
                    .foregroundStyle(.red)
            }
            
            HStack {
                if #available(anyAppleOS 27, *) {
                    Menu("Add images", systemImage: "plus") {
                        Button("Photo Library", systemImage: "photo.on.rectangle") {
                            showsPhotoPicker = true
                        }
                        #if os(iOS)
                        Button("Take Photo", systemImage: "camera") {
                            isFocused = false
                            Task { await vm.openCamera() }
                        }
                        .disabled(!ChatCameraView.isAvailable)
                        #endif
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.primary)
                    .disabled(vm.isResponding || vm.isLoadingImages)
                    .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhotos, maxSelectionCount: 4, matching: .images)
                }
                
                if vm.isLoadingImages {
                    ProgressView("Loading images")
                        .caption()
                }
                
                Spacer()
                
                if vm.isResponding {
                    ProgressView()
                        .accessibilityLabel("Generating response")
                }
                
                Button("Send message", systemImage: "arrow.up") {
                    isFocused = false
                    Task { await vm.sendPrompt() }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(.primary)
                .foregroundStyle(.background)
                .bold()
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.primary.opacity(0.08))
        }
        .padding(.horizontal)
        .padding(.bottom)
        .task {
            await Task.yield()
            isFocused = true
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $vm.showsCamera) {
            ChatCameraView { data in
                vm.addCameraImage(data)
            }
            .ignoresSafeArea()
        }
        #endif
        .task(id: selectedPhotos) {
            await vm.loadImages(selectedPhotos)
            if !selectedPhotos.isEmpty {
                selectedPhotos = []
            }
        }
    }
}
