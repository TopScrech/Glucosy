import ScrechKit

@main
struct GlucosyWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Lock-screen
        ACGlucoseWidget()
        ACCarbsWidget()
        SSGlucoseWidget()
        
#if canImport(ActivityKit)
        GlucosyWidgetLiveActivity()
#endif
    }
}
