import ScrechKit

@main
struct GlucosyWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlucosyWidget()
#if canImport(ActivityKit)
        GlucosyWidgetLiveActivity()
#endif
    }
}
