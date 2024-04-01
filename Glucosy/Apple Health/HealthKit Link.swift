import ScrechKit

struct HealthKitLinks: View {
    var body: some View {
        Section {
            Button {
                openHealthApp()
            } label: {
                HStack {
                    Image(.appleHealth)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .shadow(radius: 2)
                    
                    Text("Apple Health")
                        .rounded()
                    
                    Spacer()
                    
                    Image(systemName: "link")
                        .semibold()
                        .foregroundStyle(.red)
                }
            }
            .foregroundStyle(.foreground)
            
            Button {
                openApp(BundleID.mySurg) {
                    print("Failed to open \(BundleID.mySurg)")
                }
            } label: {
                HStack {
                    Image(.mySugr)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(.rect(cornerRadius: 8))
                        .shadow(radius: 2)
                    
                    Text("mySugr")
                        .rounded()
                        .foregroundStyle(.foreground)
                    
                    Spacer()
                    
                    Image(systemName: "link")
                        .semibold()
                        .foregroundStyle(.green)
                }
            }
            
            Button {
                openApp(BundleID.librelinkNL) {
                    print("Failed to open \(BundleID.librelinkNL)")
                }
            } label: {
                HStack {
                    Image(.librelink)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(.rect(cornerRadius: 8))
                        .shadow(radius: 2)
                    
                    Text("Freestyle NL")
                        .rounded()
                        .foregroundStyle(.foreground)
                    
                    Spacer()
                    
                    Image(systemName: "link")
                        .semibold()
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

#Preview {
    List {
        HealthKitLinks()
    }
    .darkSchemePreferred()
}
