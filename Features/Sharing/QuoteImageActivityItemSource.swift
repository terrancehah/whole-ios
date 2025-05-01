import UIKit

/// Custom activity item source for sharing a quote image, ensuring the preview is always shown.
struct QuoteImageActivityItemSource: UIActivityItemSource {
    let image: UIImage

    // This is used for the preview in the share sheet.
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    // This is the actual item that will be shared.
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    // Optional: Provide a subject for email, etc.
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Shared Quote"
    }
}
