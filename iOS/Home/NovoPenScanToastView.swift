import SwiftUI

struct NovoPenScanToastView: View {
    let title: String
    let showsViewAll: Bool
    let viewAll: () -> Void
    let dismiss: () -> Void
    
    var body: some View {
        if #available(iOS 26, visionOS 26, *) {
            HStack {
                Image(systemName: "wave.3.right")
                    .font(.title3)
                
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                if showsViewAll {
                    Button("View All", systemImage: "list.bullet", action: viewAll)
                        .labelStyle(.titleOnly)
                        .foregroundStyle(.tint)
                }
            }
            .padding(.horizontal)
            .frame(height: 50)
            .clipShape(.capsule)
            .contentShape(.capsule)
            .glassEffect(.regular, in: .capsule)
            .gesture(
                DragGesture()
                    .onEnded {
                        if $0.translation.height > 30 {
                            dismiss()
                        }
                    }
            )
        } else {
            HStack {
                Image(systemName: "wave.3.right")
                    .font(.title3)
                
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                if showsViewAll {
                    Button("View All", systemImage: "list.bullet", action: viewAll)
                        .labelStyle(.titleOnly)
                        .foregroundStyle(.tint)
                }
            }
            .padding(.horizontal)
            .frame(height: 50)
            .background(.regularMaterial, in: .capsule)
            .clipShape(.capsule)
            .contentShape(.capsule)
            .gesture(
                DragGesture()
                    .onEnded {
                        if $0.translation.height > 30 {
                            dismiss()
                        }
                    }
            )
        }
    }
}

#Preview {
    NovoPenScanToastView(
        title: "3 new NovoPen doses",
        showsViewAll: true,
        viewAll: {},
        dismiss: {}
    )
    .padding()
}
