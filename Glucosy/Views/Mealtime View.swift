import SwiftUI

struct MealtimeView: View {
    @Environment(AppState.self) private var app: AppState
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("amount_insulin") private var amountInsulin = 5.0
    @AppStorage("selected_insulin") private var selectedInsulin: InsulinType = .bolus
    
    private let insulinTypes: [InsulinType] = [
        .basal, // Long
        .bolus  // Short
    ]
    
    @State private var recordDate = Date()
    @State private var previousValue = 0.0
    
    private var timeDifference: String {
        timeDifferenceFromNow(recordDate)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            DatePicker("Date and time", selection: $recordDate)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            Text(timeDifference)
            
            Picker("Insulin Type", selection: $selectedInsulin) {
                ForEach(insulinTypes, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            HStack(spacing: 50) {
                Button {
                    previousValue = amountInsulin
                    amountInsulin -= 1
                } label: {
                    Text("-1")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.red, in: .rect(cornerRadius: 16))
                }
                
                Text(amountInsulin)
                    .monospaced()
                    .animation(.default, value: amountInsulin)
//                    .modifier(NumericContentTransitionModifier(newValue: amountInsulin, oldValue: vm.previousValue))
                
                Button {
                    previousValue = amountInsulin
                    amountInsulin += 1
                } label: {
                    Text("+1")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.green, in: .rect(cornerRadius: 16))
                }
            }
            .title(.semibold)
            
            Spacer()
            
            Button {
//                app.main.healthKit?.writeInsulinDelivery([])
//                vm.saveInsulinDelivery(amount: amountInsulin, type: selectedInsulin, date: vm.recordDate) // METADATA
                dismiss()
            } label: {
                Text("Save")
                    .title3(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: .infinity, height: 60)
                    .frame(maxWidth: .infinity)
                    .background(.blue, in: .rect(cornerRadius: 20))
            }
            .padding(.horizontal)
        }
        .task {
            previousValue = amountInsulin
        }
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
