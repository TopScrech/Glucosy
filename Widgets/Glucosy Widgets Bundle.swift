import SwiftUI

@main
struct GlucosyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        GlucosyWidgets()
        
        if #available(iOS 18, *) {
            GlucosyWidgetsControl()
        }
    }
}
