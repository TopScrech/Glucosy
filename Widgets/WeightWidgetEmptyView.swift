import ScrechKit

struct WeightWidgetEmptyView: View {
    let errorDescription: String?
    
    private var title: String {
        errorDescription ?? "No Weight Entries"
    }
    
    var body: some View {
        ContentUnavailableView(title, systemImage: "scalemass")
            .caption()
            .secondary()
    }
}
