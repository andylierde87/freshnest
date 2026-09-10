import Foundation

protocol ScanPhotoStoring: Sendable {
    /// Persists JPEG data and returns a relative path to store on the scan record.
    func savePhoto(_ data: Data) throws -> String
    func loadPhoto(at relativePath: String) -> Data?
    func deletePhoto(at relativePath: String)
}

enum ScanPhotoStoreError: Error {
    case directoryUnavailable
}

/// Stores scan photos under Documents/ScanPhotos. Respecting the user's
/// "Store Scan Photos" setting is the caller's responsibility — this type
/// only persists whatever bytes it is given.
struct FileSystemScanPhotoStore: ScanPhotoStoring {
    private let directoryName = "ScanPhotos"

    private var directoryURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documents.appendingPathComponent(directoryName, isDirectory: true)
    }

    func savePhoto(_ data: Data) throws -> String {
        guard let directoryURL else { throw ScanPhotoStoreError.directoryUnavailable }

        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return "\(directoryName)/\(fileName)"
    }

    func loadPhoto(at relativePath: String) -> Data? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = documents.appendingPathComponent(relativePath)
        return try? Data(contentsOf: url)
    }

    func deletePhoto(at relativePath: String) {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let url = documents.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
    }
}
