import ScrechKit

@main
struct GlucosyWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Lock-screen
        ACGlucoseWidget()
        ACCarbsWidget()
        
        GlucosyWidget()
        
#if canImport(ActivityKit)
        GlucosyWidgetLiveActivity()
#endif
    }
}
