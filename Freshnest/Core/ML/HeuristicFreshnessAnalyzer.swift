import CoreGraphics
import Foundation

/// Deterministic, fully on-device visible-condition estimate derived from
/// actual pixel data (never random). Downsamples the photo and buckets
/// pixels into simple color families to approximate common visible
/// spoilage cues (browning, dark/mold-like patches, yellowing).
///
/// This is intentionally a lightweight heuristic rather than a trained
/// model — it can be swapped for a bundled Core ML model behind the same
/// `FreshnessAnalyzing` protocol without touching any call site.
struct HeuristicFreshnessAnalyzer: FreshnessAnalyzing {
    private let sampleDimension = 48

    func analyze(image: CGImage, foodID: String) async throws -> FreshnessAnalysisResult {
        let pixels = try samplePixels(from: image, dimension: sampleDimension)
        let buckets = classify(pixels: pixels)

        let total = max(1, buckets.total)
        let brownRatio = Double(buckets.brown) / Double(total)
        let darkRatio = Double(buckets.veryDark) / Double(total)
        let yellowRatio = Double(buckets.yellow) / Double(total)
        let greenRatio = Double(buckets.green) / Double(total)
        let produceRatio = Double(buckets.brown + buckets.veryDark + buckets.yellow + buckets.green) / Double(total)

        var score = 96.0
        score -= brownRatio * 140
        score -= darkRatio * 170
        score -= max(0, yellowRatio - 0.35) * 60

        let clampedScore = FreshnessStateMapper.clamp(Int(score.rounded()))
        let state = FreshnessStateMapper.state(forScore: clampedScore)

        var observations: [VisibleObservation] = []
        if greenRatio > 0.2 { observations.append(.greenArea) }
        if yellowRatio > 0.35 { observations.append(.yellowing) }
        if brownRatio > 0.05 { observations.append(.brownSpots) }
        if darkRatio > 0.12 { observations.append(.darkSpots) }
        if darkRatio > 0.22 && brownRatio > 0.1 { observations.append(.moldLikePattern) }
        if observations.isEmpty && produceRatio < 0.15 { observations.append(.unknown) }

        let confidence = min(0.95, max(0.3, 0.35 + produceRatio * 0.6))

        return FreshnessAnalysisResult(
            score: clampedScore,
            state: state,
            confidence: confidence,
            visibleObservations: observations
        )
    }

    // MARK: - Pixel sampling

    private struct PixelBuckets {
        var green = 0
        var yellow = 0
        var brown = 0
        var veryDark = 0
        var other = 0
        var total: Int { green + yellow + brown + veryDark + other }
    }

    private func samplePixels(from image: CGImage, dimension: Int) throws -> [(r: Double, g: Double, b: Double)] {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = dimension * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: dimension * dimension * bytesPerPixel)

        guard let context = CGContext(
            data: &rawData,
            width: dimension,
            height: dimension,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw FreshnessAnalyzingError.imageProcessingFailed
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: dimension, height: dimension))

        var pixels: [(r: Double, g: Double, b: Double)] = []
        pixels.reserveCapacity(dimension * dimension)
        for y in 0..<dimension {
            for x in 0..<dimension {
                let offset = (y * dimension + x) * bytesPerPixel
                let r = Double(rawData[offset]) / 255.0
                let g = Double(rawData[offset + 1]) / 255.0
                let b = Double(rawData[offset + 2]) / 255.0
                pixels.append((r, g, b))
            }
        }
        return pixels
    }

    private func classify(pixels: [(r: Double, g: Double, b: Double)]) -> PixelBuckets {
        var buckets = PixelBuckets()
        for pixel in pixels {
            let (h, s, v) = hsb(r: pixel.r, g: pixel.g, b: pixel.b)

            if v < 0.18 {
                buckets.veryDark += 1
            } else if s < 0.1 && v > 0.85 {
                buckets.other += 1 // near-white background/plate
            } else if h >= 70 && h <= 170 && s > 0.15 {
                buckets.green += 1
            } else if h >= 40 && h < 70 {
                buckets.yellow += 1
            } else if (h < 40 || h > 340) && v < 0.6 && s > 0.2 {
                buckets.brown += 1
            } else {
                buckets.other += 1
            }
        }
        return buckets
    }

    private func hsb(r: Double, g: Double, b: Double) -> (h: Double, s: Double, v: Double) {
        let maxV = max(r, g, b)
        let minV = min(r, g, b)
        let delta = maxV - minV

        var hue = 0.0
        if delta > 0.0001 {
            if maxV == r {
                hue = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
            } else if maxV == g {
                hue = 60 * (((b - r) / delta) + 2)
            } else {
                hue = 60 * (((r - g) / delta) + 4)
            }
        }
        if hue < 0 { hue += 360 }

        let saturation = maxV == 0 ? 0 : delta / maxV
        return (hue, saturation, maxV)
    }
}
