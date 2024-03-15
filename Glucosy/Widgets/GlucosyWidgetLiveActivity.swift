#if canImport(ActivityKit)

import SwiftUI
import WidgetKit
import ActivityKit

struct GlucosyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here
        var emoji: String
    }
    
    // Fixed non-changing properties about your activity go here
    var name: String
}

struct GlucosyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlucosyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(.cyan)
            .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GlucosyWidgetAttributes {
    fileprivate static var preview: GlucosyWidgetAttributes {
        GlucosyWidgetAttributes(name: "World")
    }
}

extension GlucosyWidgetAttributes.ContentState {
    fileprivate static var smiley: GlucosyWidgetAttributes.ContentState {
        GlucosyWidgetAttributes.ContentState(emoji: "😀")
    }
    
    fileprivate static var starEyes: GlucosyWidgetAttributes.ContentState {
        GlucosyWidgetAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: GlucosyWidgetAttributes.preview) {
    GlucosyWidgetLiveActivity()
} contentStates: {
    GlucosyWidgetAttributes.ContentState.smiley
    GlucosyWidgetAttributes.ContentState.starEyes
}

#endif // canImport(ActivityKit)
