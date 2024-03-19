import SwiftUI

struct MealtimeNotification: View {
    @Environment(AppState.self) private var app: AppState
    
    @Binding private var sheetMeal: Bool
    
    init(_ sheetMeal: Binding<Bool>) {
        _sheetMeal = sheetMeal
    }
    
    var body: some View {
        HStack {
            Text(app.trendArrow.symbol)
                .title()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(app.currentGlucose.units)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(app.sensor.type.rawValue)
                    .textScale(.secondary)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 20)
            
            Spacer(minLength: 0)
            
            Group {
                Button {
                    sheetMeal = true
                } label: {
                    Image(systemName: "syringe.fill")
                }
                .tint(.purple)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                
                Button {
                    sheetMeal = true
                } label: {
                    Image(systemName: "fork.knife")
                }
                .tint(.orange)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
            .title2()
            .offset(y: 8)
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.black)
        }
    }
}

#Preview {
    MealtimeNotification(.constant(false))
        .glucosyPreview()
}
