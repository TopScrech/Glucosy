import Foundation
import ImageIO

struct ChatImageAttachment: Identifiable {
    let id = UUID()
    let image: CGImage

    init?(data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 1536
              ] as CFDictionary) else {
            return nil
        }
        self.image = image
    }
}
