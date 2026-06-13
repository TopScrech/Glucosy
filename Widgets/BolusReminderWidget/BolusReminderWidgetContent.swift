import ScrechKit
import WidgetKit
import AppIntents

struct BasalReminderWidgetContent: View {
    let entry: BasalReminderEntry
    
    @AppStorage(BasalReminderAppStorage.skippedDateKey, store: BasalReminderAppStorage.userDefaults)
    private var skippedDateTimestamp = 0.0
    
    private var isComplete: Bool {
        entry.basalCount > 0 || isSkippedToday
    }
    
    private var isSkippedToday: Bool {
        entry.isSkippedToday || Calendar.current.isDate(
            Date(timeIntervalSince1970: skippedDateTimestamp),
            inSameDayAs: .now
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if entry.errorDescription == nil {
                HStack(spacing: 8) {
                    if !isComplete {
                        Button("Done", systemImage: "checkmark", intent: MarkBasalReminderDoneIntent())
                            .buttonBorderShape(.circle)
                        
                        Spacer()
                        
                        Link(destination: scanURL) {
                            Label("Scan", systemImage: "wave.3.right")
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    }
                }
                .controlSize(.small)
                .labelStyle(.iconOnly)
                
                Spacer()
            }
            
            Image(systemName: isComplete ? "checkmark.circle.fill" : "syringe.fill")
                .foregroundStyle(isComplete ? .green : .purple)
                .title()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(headerTitle)
                .title3(.semibold, design: .rounded)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer(minLength: 0)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .title3(.semibold, design: .rounded)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .caption()
                        .secondary()
                        .lineLimit(2)
                }
            }
        }
    }
    
    private var headerTitle: LocalizedStringKey {
        isComplete ? "Basal taken" : "Take Basal"
    }
    
    private var title: LocalizedStringKey? {
        if let _ = entry.errorDescription {
            "Check Basal"
        } else if entry.basalCount > 0 {
            nil
        } else if isSkippedToday {
            nil
        } else {
            nil
        }
    }
    
    private var scanURL: URL {
        URL(string: "glucosy://startNovoPenScan")!
    }
    
    private var subtitle: LocalizedStringKey? {
        if let _ = entry.errorDescription {
            "Open Glucosy to refresh your records"
        } else if entry.basalCount > 0 {
            nil
        } else if isSkippedToday {
            nil
        } else {
            nil
        }
    }
}
