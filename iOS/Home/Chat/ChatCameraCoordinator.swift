#if os(iOS)
import UIKit

final class ChatCameraCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let onCapture: (Data?) -> Void
    private let onDismiss: () -> Void

    init(onCapture: @escaping (Data?) -> Void, onDismiss: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onDismiss = onDismiss
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        onCapture(image?.jpegData(compressionQuality: 0.9))
        onDismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onDismiss()
    }
}
#endif
