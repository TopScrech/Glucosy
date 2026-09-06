import SwiftUI

struct ChatImageStrip: View {
    let attachments: [ChatImageAttachment]
    var onRemove: ((UUID) -> Void)?

    @ScaledMetric private var thumbnailSize = 72

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(attachments) { attachment in
                    Image(decorative: attachment.image, scale: 1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .clipShape(.rect(cornerRadius: 12))
                        .accessibilityLabel("Attached photo")
                        .overlay(alignment: .topTrailing) {
                            if let onRemove {
                                Button("Remove image", systemImage: "xmark.circle.fill") {
                                    onRemove(attachment.id)
                                }
                                .labelStyle(.iconOnly)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black.opacity(0.6))
                                .padding(.leading)
                                .padding(.bottom)
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
