import ScrechKit

struct HealthKitLink: View {
    var body: some View {
        Button {
            openHealthApp()
        } label: {
            HStack {
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .shadow(radius: 2)
                
                Text("Apple Health")
                    .rounded()
                
                Spacer()
                
                Image(systemName: "link")
                    .semibold()
                    .foregroundStyle(.blue)
            }
        }
        .foregroundStyle(.foreground)
    }
}

#Preview {
    List {
        HealthKitLink()
    }
}
