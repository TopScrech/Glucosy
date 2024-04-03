import SwiftUI

struct CalibrationForm: View {
    @Environment(Settings.self) private var settings: Settings
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var settings = settings
        
        Form {
            Section("Calibration Info") {
                HStack {
                    Text("i1")
                    
                    TextField("i1", value: $settings.activeSensorCalibrationInfo.i1, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("i2")
                    
                    TextField("i2", value: $settings.activeSensorCalibrationInfo.i2, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("i3")
                    
                    TextField("i3", value: $settings.activeSensorCalibrationInfo.i3, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("i4")
                    
                    TextField("i4", value: $settings.activeSensorCalibrationInfo.i4, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("i5")
                    
                    TextField("i5", value: $settings.activeSensorCalibrationInfo.i5, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("i6")
                    
                    TextField("i6", value: $settings.activeSensorCalibrationInfo.i6, formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                }
            }
            
            Button("Set") {
                dismiss()
            }
            .bold()
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            CalibrationForm()
                .glucosyPreview()
        }
}
