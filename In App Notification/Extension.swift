import SwiftUI

extension UIApplication {
    func inAppNotification <Content: View>(
        isDynamicIsland: Bool = false,
        timeout: CGFloat = 5,
        swipeToClose: Bool = true,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        /// Fetching Active Window via WindowScene
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
            /// Frame and SafeArea Values
            let frame = activeWindow.frame
            let safeArea = activeWindow.safeAreaInsets
            
            var tag = 1009
            let checkForDynamicIsland = isDynamicIsland && safeArea.top >= 51
            
            if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
                tag = previousTag + 1
            }
            
            UserDefaults.standard.setValue(tag, forKey: "in_app_notification_tag")
            
            /// Changing Status into Black to blend with Dynamic Island
            if checkForDynamicIsland {
                if let controller = activeWindow.rootViewController as? StatusBarBasedController {
                    controller.statusBarStyle = .darkContent
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
            
            /// Creating UIView from SwiftUIView using UIHosting Configuration
            let config = UIHostingConfiguration {
                AnimatedNotificationView(
                    content: content(checkForDynamicIsland),
                    safeArea: safeArea,
                    tag: tag,
                    isDynamicIsland: checkForDynamicIsland,
                    timeout: timeout,
                    swipeToClose: swipeToClose
                )
                /// Maximum Notification Height will be 120
                .frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 100, alignment: .top)
                //                .frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
                .contentShape(.rect)
            }
            
            /// Creating UIView
            let view = config.makeContentView()
            view.tag = tag
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if let rootView = activeWindow.rootViewController?.view {
                /// Adding View to the Window
                rootView.addSubview(view)
                
                /// Layout Constraints
                view.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: (-(frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
            }
        }
    }
}

fileprivate struct AnimatedNotificationView <Content: View>: View {
    var content: Content
    var safeArea: UIEdgeInsets
    var tag: Int
    var isDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    
    @State private var animateNotification = false
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        content
            .opacity(isDynamicIsland ? (animateNotification ? 1 : 0) : 1)
            .blur(radius: animateNotification ? 0 : 10)
            .disabled(!animateNotification)
            .size {
                viewSize = $0
            }
            .background {
                if isDynamicIsland {
                    Rectangle()
                        .fill(.black)
                }
            }
            .mask {
                if isDynamicIsland {
                    /// Size Based Capusule
                    GeometryReader { geometry in
                        let size = geometry.size
                        let radius = size.height / 2
                        
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                    }
                } else {
                    Rectangle()
                }
            }
        /// Scaling Animation only For Dynamic Island Notification
        /// Approx Dynamic Island Size = (126, 37.33)
            .scaleEffect(
                x: isDynamicIsland ? (animateNotification ? 1 : (120 / viewSize.width)) : 1,
                y: isDynamicIsland ? (animateNotification ? 1 : (35 / viewSize.height)) : 1,
                anchor: .top
            )
        /// Offset Animation for Non Dynamic Island Notification
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if -value.translation.height > 50 && swipeToClose {
                            withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                                animateNotification = false
                            } completion: {
                                removeNotificationViewFromWindow()
                            }
                        }
                    }
            )
            .onAppear {
                Task {
                    guard !animateNotification else { 
                        return
                    }
                    
                    withAnimation(.smooth) {
                        animateNotification = true
                    }
                    
                    /// Timeout For Notification
                    try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
                    
                    guard animateNotification else { 
                        return
                    }
                    
                    withAnimation(.smooth, completionCriteria: .logicallyComplete) {
                        animateNotification = false
                    } completion: {
                        removeNotificationViewFromWindow()
                    }
                }
            }
    }
    
    var offsetY: CGFloat {
        if isDynamicIsland {
            animateNotification ? 0 : 1.33
        } else {
            animateNotification ? 10 : -(safeArea.top + 130)
        }
    }
    
    func removeNotificationViewFromWindow() {
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
            
            if let view = activeWindow.viewWithTag(tag) {
                //print("Removed View with \(tag)")
                view.removeFromSuperview()
                
                /// Resetting Once All the notifications was removed
                if let controller = activeWindow.rootViewController as? StatusBarBasedController, controller.view.subviews.isEmpty {
                    controller.statusBarStyle = .default
                    controller.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
}

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

fileprivate extension View {
    func size(value: @escaping (CGSize) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    Color.clear
                        .preference(key: SizeKey.self, value: size)
                        .onPreferenceChange(SizeKey.self) {
                            value($0)
                        }
                }
            }
    }
}

class StatusBarBasedController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
}

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        return rootViewController?.view == view ? nil : view
    }
}
