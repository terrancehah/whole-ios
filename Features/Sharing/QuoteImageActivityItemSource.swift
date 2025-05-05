import UIKit

/// Custom activity item source for sharing a quote image, ensuring the preview is always shown.
/// Must be a class inheriting from NSObject to conform to UIActivityItemSource.
class QuoteImageActivityItemSource: NSObject, UIActivityItemSource {
    let image: UIImage

    // Initializer for the image to share
    init(image: UIImage) {
        self.image = image
    }

    // Used for the preview in the share sheet
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    // The actual item that will be shared
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    // Optional: Provide a subject for email, etc.
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Shared Quote"
    }
}
