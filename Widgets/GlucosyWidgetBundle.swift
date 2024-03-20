import ScrechKit

@main
struct GlucosyWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleWidget()
        
        GlucosyWidget()
        
#if canImport(ActivityKit)
        GlucosyWidgetLiveActivity()
#endif
    }
}
