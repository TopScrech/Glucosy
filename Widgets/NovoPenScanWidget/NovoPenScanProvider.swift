import WidgetKit

struct NovoPenScanProvider: TimelineProvider {
    func placeholder(in context: Context) -> NovoPenScanEntry {
        NovoPenScanEntry(date: .now)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NovoPenScanEntry) -> Void) {
        completion(NovoPenScanEntry(date: .now))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NovoPenScanEntry>) -> Void) {
        completion(Timeline(entries: [NovoPenScanEntry(date: .now)], policy: .never))
    }
}
