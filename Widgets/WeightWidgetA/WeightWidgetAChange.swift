import ScrechKit

struct WeightWidgetAChange: View {
    let value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Change")
                .caption2()
                .secondary()
            
            Spacer(minLength: 4)
            
            Text(value)
                .caption(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}
