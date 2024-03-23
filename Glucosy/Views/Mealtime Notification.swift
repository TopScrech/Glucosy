import SwiftUI

struct MealtimeNotification: View {
    @Environment(AppState.self) private var app: AppState
    
    @Binding private var sheetMeal: Bool
    
    init(_ sheetMeal: Binding<Bool>) {
        _sheetMeal = sheetMeal
    }
    
    private var trendArrow: String {
        app.trendArrow.symbol
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(app.currentGlucose.units)
                .title()
                .bold()
                .foregroundStyle(.white)
            
            if trendArrow != "---" {
                Text(app.trendArrow.symbol)
                    .title()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
            }
            
            Spacer()
            
            Group {
                HStack(spacing: 0) {
                    Button {
                        sheetMeal = true
                    } label: {
                        Image(systemName: "syringe.fill")
                            .frame(width: 25, height: 25)
                    }
                    .tint(.purple)
                    
                    Button {
                        sheetMeal = true
                    } label: {
                        Image(systemName: "fork.knife")
                            .frame(width: 25, height: 25)
                    }
                    .tint(.orange)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .padding(4)
                .background(.tertiary.opacity(0.3), in: .capsule)
            }
            .title2()
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.black)
        }
    }
}

#Preview {
    GeometryReader { _ in
        MealtimeNotification(.constant(false))
    }
    .background(.gray)
    .glucosyPreview()
}
