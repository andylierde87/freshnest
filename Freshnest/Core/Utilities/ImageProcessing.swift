import UIKit

/// Keeps scan photo handling memory-conscious: ML input and stored
/// thumbnails are always downscaled, never full resolution.
enum ImageProcessing {
    static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension, largestSide > 0 else { return image }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    static func cgImage(from image: UIImage, maxDimension: CGFloat = 640) -> CGImage? {
        resized(image, maxDimension: maxDimension).cgImage
    }

    static func jpegThumbnailData(from image: UIImage, maxDimension: CGFloat = 480, quality: CGFloat = 0.7) -> Data? {
        resized(image, maxDimension: maxDimension).jpegData(compressionQuality: quality)
    }
}
