import SwiftUI

struct MealtimeView: View {
    @Environment(AppState.self) private var app: AppState
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("rapid_insulin") private var rapidInsulin = 5.0
    @AppStorage("long_insulin") private var longInsulin = 5.0
    @AppStorage("carbs") private var carbs = 50.0
    @AppStorage("selected_insulin") private var selectedInsulin: InsulinType = .bolus
    
    @State private var date = Date()
    
    private var timeDifference: String {
        timeDifferenceFromNow(date)
    }
    
    //    @State private var includeGlucose = false
    @State private var includeRapidInsulin = false
    @State private var includeLongInsulin = false
    @State private var includeCarbs = false
    
    @State private var setReminder = false
    
    var body: some View {
        VStack(spacing: 25) {
            DatePicker("Record time", selection: $date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            Text(timeDifference)
            
            VStack(alignment: .leading) {
                Button {
                    includeRapidInsulin.toggle()
                } label: {
                    Label("Rapid-acting insulin", systemImage: includeRapidInsulin ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                }
            }
            
            if includeRapidInsulin {
                MealtimeSelector($rapidInsulin)
            }
            
            VStack(alignment: .leading) {
                Button {
                    includeLongInsulin.toggle()
                } label: {
                    Label("Long-acting insulin", systemImage: includeLongInsulin ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                }
            }
            
            if includeLongInsulin {
                MealtimeSelector($longInsulin)
            }
            
            VStack(alignment: .leading) {
                Button {
                    includeCarbs.toggle()
                } label: {
                    Label("Carbs", systemImage: includeCarbs ? "checkmark.square" : "square")
                        .foregroundStyle(.foreground)
                }
            }
            
            if includeCarbs {
                MealtimeSelector($carbs)
            }
            
            Toggle("Set measure reminder in 2 hours", isOn: $setReminder)
            
            Spacer()
            
            Button {
                saveData()
            } label: {
                Text("Save")
                    .title3(.semibold)
                    .foregroundStyle(.white)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: .rect(cornerRadius: 20))
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private func saveData() {
        if includeRapidInsulin {
            let rapidInsulinDelivery = InsulinDelivery(
                value: Int(rapidInsulin),
                type: .bolus,
                date: date
            )
            
            app.main.healthKit?.writeInsulinDelivery(rapidInsulinDelivery)
        }
        
        if includeLongInsulin {
            let longInsulinDelivery = InsulinDelivery(
                value: Int(longInsulin),
                type: .basal,
                date: date
            )
            
            app.main.healthKit?.writeInsulinDelivery(longInsulinDelivery)
        }
        
        if includeRapidInsulin || includeLongInsulin {
            app.main.healthKit?.readInsulin()
        }
        
        if includeCarbs {
            let carbohydrates = Carbohydrates(value: Int(carbs), date: date)
            
            app.main.healthKit?.writeCarbs([carbohydrates])
            app.main.healthKit?.readCarbs()
        }
        
        if setReminder {
            NotificationManager.shared.scheduleScanReminder()
        }
        
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
    MealtimeView()
        .glucosyPreview()
}
