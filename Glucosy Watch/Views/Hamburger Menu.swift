import SwiftUI

struct HamburgerMenu: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 4) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: Monitor()) {
                            VStack {
                                Image(systemName: "gauge")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Monitor")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: Details()) {
                            VStack {
                                Image(.bluetooth)
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Details")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, -4)
                    
                    HStack(spacing: 10) {
                        NavigationLink(destination: Console()) {
                            VStack {
                                Image(systemName: "terminal")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Console")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            VStack {
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Settings")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        NavigationLink(destination: DataView()) {
                            VStack {
                                Image(systemName: "tray.full.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Data")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: OnlineView()) {
                            VStack {
                                Image(systemName: "globe")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .offset(y: 4)
                                
                                Text("Online")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // TODO: Help and About sheets
                    //                    HStack(spacing: 10) {
                    //                        VStack {
                    //                            Image(systemName: "questionmark.circle")
                    //                                .resizable()
                    //                                .frame(width: 40, height: 40)
                    //                                .offset(y: 4)
                    //                            Text("Help")
                    //                                .bold()
                    //                                .foregroundColor(.blue)
                    //                        }
                    //                        .frame(maxWidth: .infinity)
                    //
                    //                        VStack {
                    //                            Image(systemName: "info.circle")
                    //                                .resizable()
                    //                                .frame(width: 40, height: 40)
                    //                                .offset(y: 4)
                    //                            Text("About")
                    //                                .bold()
                    //                                .foregroundColor(.blue)
                    //                        }
                    //                        .frame(maxWidth: .infinity)
                    //                    }
                }
                .foregroundColor(.red)
                
                Spacer(minLength: 30)
                
                VStack(spacing: 20) {
                    VStack {
                        Text("Glucosy  \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)  (\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))")
                        
                        // TODO: get AppIcon 1024x1024
                        // Image("AppIcon").resizable().frame(width: 100, height: 100)
                        // FIXME: crashes in TestFlight (not in Release scheme)
                        if UIImage(named: "AppIcon") != nil {
                            Image(uiImage: UIImage(named: "AppIcon")!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        
                        Link("https://github.com/gui-dos/DiaBLE", destination: URL(string: "https://github.com/gui-dos/DiaBLE")!)
                            .foregroundColor(.blue)
                    }
                    
                    VStack {
                        Image(systemName: "envelope.fill")
                        
                        Link(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string,
                             destination: URL(string: "mailto:\(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string)")!)
                        .foregroundColor(.blue)
                    }
                    
                    VStack {
                        Image(systemName: "giftcard")
                        
                        Link(Data(base64Encoded: "aHR0cHM6Ly9wYXlwYWwubWUvZ3Vpc29y")!.string, destination: URL(string: Data(base64Encoded: "aHR0cHM6Ly9wYXlwYWwubWUvZ3Vpc29y")!.string)!)
                            .foregroundColor(.blue)
                    }
                }
                .foregroundColor(.white)
            }
            .buttonStyle(.borderless)
            .navigationTitle("Glucosy")
            .tint(.blue)
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding(.top, -4)
        .edgesIgnoringSafeArea([.bottom])
    }
}

#Preview {
    HamburgerMenu()
        .darkSchemePreferred()
}
