import Foundation
import R2Shared
import R2Streamer

struct EPUBContent {
    let html: String
    let baseURL: URL
    let title: String
}

enum EPUBError: LocalizedError {
    case downloadFailed
    case invalidFileFormat
    case fileNotFound
    case epubParsingFailed
    case resourceNotFound
    case htmlExtractionFailed
    
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
        case .htmlExtractionFailed:
            return "Impossible d'extraire le contenu HTML"
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
    
    func downloadAndLoadBook(url: URL) async throws -> EPUBContent {
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
    
    private func extractContent(from data: Data, bookURL: URL) async throws -> EPUBContent {
        let localURL = try await saveToTemporaryFile(data: data)
        
        guard let publication = try? streamer.open(asset: FileAsset(url: localURL)) else {
            throw EPUBError.epubParsingFailed
        }
        
        var htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, system-ui;
                    line-height: 1.6;
                    padding: 20px;
                    margin: 0;
                }
                img {
                    max-width: 100%;
                    height: auto;
                }
            </style>
        </head>
        <body>
        """
        
        for link in publication.readingOrder {
            guard let resource = try? publication.get(link),
                  let resourceData = try? await resource.read().data(upTo: Int.max),
                  let content = String(data: resourceData, encoding: .utf8) else {
                continue
            }
            htmlContent += "\n" + content
        }
        
        htmlContent += "\n</body></html>"
        
        if htmlContent == """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: -apple-system, system-ui;
                        line-height: 1.6;
                        padding: 20px;
                        margin: 0;
                    }
                    img {
                        max-width: 100%;
                        height: auto;
                    }
                </style>
            </head>
            <body>
            </body></html>
            """ {
            throw EPUBError.htmlExtractionFailed
        }
        
        return EPUBContent(
            html: htmlContent,
            baseURL: localURL.deletingLastPathComponent(),
            title: publication.metadata.title
        )
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