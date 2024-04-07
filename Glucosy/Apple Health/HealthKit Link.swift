import ScrechKit

struct HealthKitLink: View {    
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
                let didOpen = openApp(BunbleId.mysurg)
                
                if didOpen {
                    print("Safari should now be open")
                } else {
                    print("Failed to open \(BunbleId.mysurg)")
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
                let didOpen = openApp(BunbleId.librelinkNL)
                
                if didOpen {
                    print("Safari should now be open")
                } else {
                    print("Failed to open \(BunbleId.librelinkNL)")
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
    
    func openApp(_ bundleID: String) -> Bool {
        guard let LSApplicationWorkspace = objc_getClass("LSApplicationWorkspace") as? NSObject.Type else {
            return false
        }
        
        guard let workspace = LSApplicationWorkspace.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject else {
            return false
        }
        
        let open = workspace.perform(Selector(("openApplicationWithBundleID:")), with: bundleID) != nil
        return open
    }
    
}

#Preview {
    List {
        HealthKitLink()
    }
    .darkSchemePreferred()
}
