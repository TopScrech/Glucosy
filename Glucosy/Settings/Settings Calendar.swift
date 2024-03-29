import SwiftUI

struct SettingsCalendar: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingCalendarPicker = false
    
    var body: some View {
        @Bindable var settings = settings
        
        Button {
            showingCalendarPicker = true
        } label: {
            Image(systemName: settings.calendarTitle != "" ? "calendar.fill" : "calendar")
        }
        .popover(isPresented: $showingCalendarPicker, arrowEdge: .bottom) {
            VStack {
                Section {
                    Button("None") {
                        settings.calendarTitle = ""
                        showingCalendarPicker = false
                        app.main.eventKit?.sync()
                    }
                    .bold()
                    .padding(.horizontal, 4)
                    .padding(2)
                    .disabled(settings.calendarTitle == "")
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
                }
                
                Section {
                    Picker("Calendar", selection: $settings.calendarTitle) {
                        let titles = [""] + (app.main.eventKit?.calendarTitles ?? [""])
                        
                        ForEach(titles, id: \.self) { title in
                            Text(title != "" ? title : "None")
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.red)
                            .padding(8)
                        
                        Toggle("High / Low", isOn: $settings.calendarAlarmIsOn)
                            .disabled(settings.calendarTitle == "")
                    }
                }
                
                Section {
                    Button(settings.calendarTitle == "" ? "Don't remind" : "Remind") {
                        showingCalendarPicker = false
                        app.main.eventKit?.sync()
                    }
                    .bold()
                    .padding(.horizontal, 4)
                    .padding(2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
                    .animation(.default, value: settings.calendarTitle)
                }
                .padding(.top, 40)
            }
            .padding(60)
        }
    }
}

#Preview {
    SettingsCalendar()
        .glucosyPreview()
}
