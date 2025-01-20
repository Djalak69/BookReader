import Foundation

enum EPUBError: LocalizedError {
    case downloadFailed
    case invalidFileFormat
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Impossible de télécharger le livre"
        case .invalidFileFormat:
            return "Format de fichier invalide"
        case .fileNotFound:
            return "Fichier introuvable"
        }
    }
}

actor EPUBService {
    private let fileManager: FileManager
    private let session: URLSession
    
    init(fileManager: FileManager = .default, session: URLSession = .shared) {
        self.fileManager = fileManager
        self.session = session
    }
    
    func downloadAndLoadBook(url: URL) async throws -> String {
        let bookData = try await downloadBook(from: url)
        return try await extractContent(from: bookData)
    }
    
    private func downloadBook(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EPUBError.downloadFailed
        }
        
        return data
    }
    
    private func extractContent(from data: Data) async throws -> String {
        // Pour cette première version, on suppose que le contenu est un simple texte
        // Plus tard, nous implémenterons le vrai parsing EPUB
        guard let content = String(data: data, encoding: .utf8) else {
            throw EPUBError.invalidFileFormat
        }
        
        return content
    }
} 