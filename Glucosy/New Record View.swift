import ScrechKit
import WidgetKit

struct NewRecordView: View {
    @Environment(AppState.self) private var app: AppState
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("rapid_insulin") private var bolus = 5.0
    @AppStorage("long_insulin")  private var basal = 5.0
    @AppStorage("carbs")         private var carbs = 50.0
    
    @State private var date = Date()
    
    private var timeDifference: String {
        timeDifferenceFromNow(date)
    }
    
    @State private var setReminder = false
    @State private var isAlertCritical = false
    
    @State private var includeBolus = false
    @State private var includeBasal = false
    @State private var includeCarbs = false
    
    @State private var fieldBolus = ""
    @State private var fieldBasal = ""
    @State private var fieldCarbs = ""
    
    @FocusState private var focusBolus: Bool
    @FocusState private var focusBasal: Bool
    @FocusState private var focusCarbs: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            DatePicker("Record time", selection: $date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            Text(timeDifference)
            
            VStack {
                Button {
                    includeBolus.toggle()
                    
                    if includeBolus {
                        focusBolus = true
                    }
                } label: {
                    Label("Rapid-acting insulin", systemImage: includeBolus ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                    
                    Image(systemName: "syringe")
                        .tint(.yellow)
                }
                
                if includeBolus {
                    TextField("Rapid-acting insulin", text: $fieldBolus)
                        .keyboardType(.decimalPad)
                        .focused($focusBolus)
                        .onChange(of: fieldBolus) { _, newValue in
                            bolus = Double(newValue) ?? 0
                        }
                }
            }
            .title2()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Button {
                    includeBasal.toggle()
                    
                    if includeBasal {
                        focusBasal = true
                    }
                } label: {
                    Label("Long-acting insulin", systemImage: includeBasal ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                    
                    Image(systemName: "syringe.fill")
                        .tint(.purple)
                }
                
                if includeBasal {
                    TextField("Long-acting insulin", text: $fieldBasal)
                        .keyboardType(.decimalPad)
                        .focused($focusBasal)
                        .onChange(of: fieldBasal) { _, newValue in
                            basal = Double(newValue) ?? 0
                        }
                }
            }
            .title2()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Button {
                    includeCarbs.toggle()
                    
                    if includeCarbs {
                        focusCarbs = true
                    }
                } label: {
                    Label("Carbs", systemImage: includeCarbs ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                    
                    Image(systemName: "fork.knife")
                        .tint(.green)
                }
                
                if includeCarbs {
                    TextField("Carbs", text: $fieldCarbs)
                        .keyboardType(.decimalPad)
                        .focused($focusCarbs)
                        .onChange(of: fieldCarbs) { _, newValue in
                            carbs = Double(newValue) ?? 0
                        }
                }
            }
            .title2()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("Scan reminder in 2 hours", isOn: $setReminder)
            
            Toggle(isOn: $isAlertCritical) {
                Label {
                    Text("Critical alert")
                    
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                } icon: {
                    
                }
            }
            .disabled(!setReminder)
            
            Spacer()
            
            Menu {
                Button {
                    saveData()
                    app.main.nfc.startSession()
                } label: {
                    Label("Save and scan", systemImage: "sensor.tag.radiowaves.forward.fill")
                }
                
                Menu {
                    Button("LibreLink NL") {
                        saveData()
                        openApp(BunbleId.librelinkNL)
                    }
                    
                    Button("mySugr") {
                        saveData()
                        openApp(BunbleId.mysurg)
                    }
                } label: {
                    Label("Save and open", systemImage: "arrowshape.turn.up.right")
                }
                
            } label: {
                Text("Save")
                    .title3(.semibold)
                    .foregroundStyle(.white)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                
            } primaryAction: {
                saveData()
            }
        }
        .padding(.top)
        .padding(.horizontal, 8)
        .task {
            bolus = Double(fieldBolus) ?? 0
            basal = Double(fieldBasal) ?? 0
            carbs = Double(fieldCarbs) ?? 0
        }
    }
    
    private func saveData() {
        if includeBolus {
            let bolusDelivery = InsulinDelivery(
                value: Int(bolus),
                type: .bolus,
                date: date
            )
            
            app.main.healthKit?.writeInsulinDelivery(bolusDelivery)
        }
        
        if includeBasal {
            let basalDelivery = InsulinDelivery(
                value: Int(basal),
                type: .basal,
                date: date
            )
            
            app.main.healthKit?.writeInsulinDelivery(basalDelivery)
        }
        
        if includeBolus || includeBasal {
            app.main.healthKit?.readInsulin()
        }
        
        if includeCarbs {
            let carbohydrates = Carbohydrates(
                value: Int(carbs),
                date: date
            )
            
            app.main.healthKit?.writeCarbs(carbohydrates)
            app.main.healthKit?.readCarbs()
        }
        
        if setReminder {
            NotificationManager.shared.scheduleScanReminder(
                isAlertCritical ? .critical : .timeSensitive
            )
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        dismiss()
    }
    
    private func timeDifferenceFromNow(_ date2: Date) -> String {
        let calendar = Calendar.current
        let date1 = Date()
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: date1, to: date2)
        var timeDifference = ""
        
        if let days = components.day, days != 0 {
            timeDifference += "\(days) day"
        }
        
        if let hours = components.hour, hours != 0 {
            if !timeDifference.isEmpty {
                timeDifference += ", "
            }
            
            timeDifference += "\(hours) hour"
        }
        
        if let minutes = components.minute, minutes != 0 {
            if !timeDifference.isEmpty {
                timeDifference += ", "
            }
            
            timeDifference += "\(minutes) minute"
        }
        
        if timeDifference.contains("-") {
            let formatted = timeDifference.replacingOccurrences(of: "-", with: "") + " ago"
            
            return formatted
            
        } else {
            return timeDifference
        }
    }
}

#Preview {
    NewRecordView()
        .glucosyPreview()
}
