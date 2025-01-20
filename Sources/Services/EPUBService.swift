import Foundation
import R2Shared
import R2Streamer

enum EPUBError: LocalizedError {
    case downloadFailed
    case invalidFileFormat
    case fileNotFound
    case epubParsingFailed
    case resourceNotFound
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Impossible de télécharger le livre"
        case .invalidFileFormat:
            return "Format de fichier invalide"
        case .fileNotFound:
            return "Fichier introuvable"
        case .epubParsingFailed:
            return "Impossible de lire le fichier ePub"
        case .resourceNotFound:
            return "Ressource introuvable dans le fichier ePub"
        }
    }
}

actor EPUBService {
    private let fileManager: FileManager
    private let session: URLSession
    private let streamer: Streamer
    private let documentsPath: URL
    
    init(fileManager: FileManager = .default, session: URLSession = .shared) {
        self.fileManager = fileManager
        self.session = session
        self.streamer = Streamer()
        self.documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func downloadAndLoadBook(url: URL) async throws -> String {
        let bookData = try await downloadBook(from: url)
        return try await extractContent(from: bookData, bookURL: url)
    }
    
    private func downloadBook(from url: URL) async throws -> Data {
        if let localData = try? loadFromCache(url: url) {
            return localData
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EPUBError.downloadFailed
        }
        
        try await saveToCache(data: data, url: url)
        return data
    }
    
    private func extractContent(from data: Data, bookURL: URL) async throws -> String {
        let localURL = try await saveToTemporaryFile(data: data)
        
        guard let publication = try? streamer.open(asset: FileAsset(url: localURL)) else {
            throw EPUBError.epubParsingFailed
        }
        
        var content = ""
        for link in publication.readingOrder {
            guard let resource = try? publication.get(link),
                  let resourceData = try? await resource.read().data(upTo: Int.max),
                  let text = String(data: resourceData, encoding: .utf8) else {
                continue
            }
            content += "\n\n" + text
        }
        
        if content.isEmpty {
            throw EPUBError.resourceNotFound
        }
        
        return content
    }
    
    private func saveToTemporaryFile(data: Data) async throws -> URL {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("epub")
        
        try data.write(to: temporaryURL)
        return temporaryURL
    }
    
    private func getCachePath(for url: URL) -> URL {
        let filename = url.lastPathComponent
        return documentsPath.appendingPathComponent("books/\(filename)")
    }
    
    private func loadFromCache(url: URL) throws -> Data? {
        let cachePath = getCachePath(for: url)
        guard fileManager.fileExists(atPath: cachePath.path) else {
            return nil
        }
        return try Data(contentsOf: cachePath)
    }
    
    private func saveToCache(data: Data, url: URL) async throws {
        let cachePath = getCachePath(for: url)
        let cacheDirectory = cachePath.deletingLastPathComponent()
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        try data.write(to: cachePath)
    }
} 