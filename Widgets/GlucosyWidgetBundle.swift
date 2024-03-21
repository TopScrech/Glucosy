import ScrechKit

@main
struct GlucosyWidgetBundle: WidgetBundle {
    var body: some Widget {
        ACGlucoseWidget()
        
        GlucosyWidget()
        
#if canImport(ActivityKit)
        GlucosyWidgetLiveActivity()
#endif
    }
}
