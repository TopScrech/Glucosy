//import SwiftUI
//
//struct HamburgerMenu: View {
//    @Environment(\.colorScheme) private var colorScheme
//    
//    @Binding var showingHamburgerMenu: Bool
//    
//    @State private var showingHelp = false
//    @State private var showingAbout = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            HStack {
//                Spacer()
//            }
//            
//            Button {
//                withAnimation {
//                    showingHelp = true
//                }
//            } label: {
//                Label("Help", systemImage: "questionmark.circle")
//            }
//            .padding(.leading, 6)
//            .padding(.top, 20)
//            .sheet(isPresented: $showingHelp) {
//                NavigationView {
//                    VStack(spacing: 40) {
//                        VStack {
//                            Text("Wiki")
//                                .headline()
//                            
//                            Link("https://github.com/gui-dos/DiaBLE/wiki",
//                                 destination: URL(string: "https://github.com/gui-dos/DiaBLE/wiki")!)
//                        }
//                        .padding(.top, 80)
//                        
//                        Text("[ TODO ]")
//                        
//                        Spacer()
//                    }
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationTitle("Help")
//                    .navigationViewStyle(.stack)
//                    .toolbar {
//                        Button("Close") {
//                            withAnimation {
//                                showingHelp = false
//                            }
//                        }
//                    }
//                    .onAppear {
//                        withAnimation {
//                            showingHamburgerMenu = false
//                        }
//                    }
//                    // TODO: click on any area
//                    .onTapGesture {
//                        withAnimation {
//                            showingHelp = false
//                        }
//                    }
//                }
//            }
//            
//            Button {
//                withAnimation { showingAbout = true }
//            } label: {
//                Label("About", systemImage: "info.circle")
//            }
//            .padding(.leading, 6)
//            .sheet(isPresented: $showingAbout) {
//                NavigationView {
//                    VStack(spacing: 40) {
//                        VStack {
//                            Text("Glucosy  \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)  (\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))")
//
//                            // TODO: get AppIcon 1024x1024
//                              Image("AppIcon")
//                                  .resizable()
//                                  .frame(width: 100, height: 100)
//                            // FIXME: crashes in TestFlight (not in Release scheme)
//                            
//                            if UIImage(named: "AppIcon") != nil {
//                                Image(uiImage: UIImage(named: "AppIcon")!)
//                                        .resizable()
//                                        .frame(width: 100, height: 100)
//                            }
//                            
//                            Link("https://github.com/gui-dos/DiaBLE",
//                                 destination: URL(string: "https://github.com/gui-dos/DiaBLE")!)
//                        }
//                        
//                        VStack {
//                            Image(systemName: colorScheme == .dark ? "envelope.fill" : "envelope")
//                            
//                            Link(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string,
//                                 destination: URL(string: "mailto:\(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string)")!)
//                        }
//                        
//                        VStack {
//                            Image(systemName: "giftcard")
//                            
//                            Link("PayPal", destination: URL(string: Data(base64Encoded: "aHR0cHM6Ly9wYXlwYWwubWUvZ3Vpc29y")!.string)!)
//                        }
//                    }
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationTitle("About")
//                    .navigationViewStyle(.stack)
//                    .toolbar {
//                        Button("Close") {
//                            withAnimation {
//                                showingAbout = false
//                            }
//                        }
//                    }
//                }
//                .onAppear {
//                    withAnimation {
//                        showingHamburgerMenu = false
//                    }
//                }
//                // TODO: click on any area
//                .onTapGesture {
//                    withAnimation {
//                        showingAbout = false
//                    }
//                }
//            }
//            
//            Spacer()
//        }
//        .background(Color(.secondarySystemBackground))
//        
//        // TODO: swipe gesture
//        .onLongPressGesture(minimumDuration: 0) {
//            withAnimation(.easeOut(duration: 0.15)) { 
//                showingHamburgerMenu = false
//            }
//        }
//    }
//}
//
//#Preview {
//    HamburgerMenu(showingHamburgerMenu: Monitor(showingHamburgerMenu: true).$showingHamburgerMenu)
//        .previewLayout(.fixed(width: 180, height: 400))
//        .glucosyPreview()
//}
