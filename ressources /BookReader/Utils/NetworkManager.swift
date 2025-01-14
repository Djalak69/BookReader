import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://bookreaderserver.onrender.com"
    private var session: URLSession
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }
    
    private func getFullURL(for path: String) -> URL? {
        print("🔍 Traitement de l'URL: \(path)")
        
        // Si l'URL est déjà complète
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            print("📍 URL déjà complète: \(path)")
            if let url = URL(string: path) {
                return url
            }
            // Si l'URL complète n'est pas valide, on essaie de la reconstruire
            if let pathComponent = path.components(separatedBy: "/").last {
                return getFullURL(for: "/covers/\(pathComponent)")
            }
            return nil
        }
        
        // Nettoyer le chemin
        var cleanPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanPath.hasPrefix("/") {
            cleanPath = String(cleanPath.dropFirst())
        }
        
        // Vérifier si c'est un endpoint valide
        if cleanPath.contains("books") {
            // Pour les téléchargements de livres
            let components = cleanPath.components(separatedBy: "/")
            if let bookId = components.first(where: { $0.count > 20 }) {
                cleanPath = "api/books/\(bookId)/download"
            }
        } else if cleanPath.contains("covers") {
            // Pour les couvertures
            if !cleanPath.hasPrefix("api/") {
                cleanPath = "api/\(cleanPath)"
            }
        }
        
        // Construire l'URL complète
        let fullURLString = "\(baseURL)/\(cleanPath)"
        print("✅ URL construite: \(fullURLString)")
        return URL(string: fullURLString)
    }
    
    func downloadFile(from urlString: String, progressHandler: ((Float) -> Void)? = nil) -> AnyPublisher<URL, Error> {
        print("📥 Tentative de téléchargement depuis: \(urlString)")
        
        guard let url = getFullURL(for: urlString) else {
            print("❌ URL invalide: \(urlString)")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        return Future<URL, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.invalidResponse))
                return
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            
            // Ajout du token d'authentification si disponible
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let downloadTask = self.session.downloadTask(with: request) { tempURL, response, error in
                if let error = error {
                    print("❌ Erreur de téléchargement: \(error.localizedDescription)")
                    promise(.failure(NetworkError.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Réponse invalide")
                    promise(.failure(NetworkError.invalidResponse))
                    return
                }
                
                print("📡 Code de réponse: \(httpResponse.statusCode)")
                print("📡 Headers détaillés:")
                httpResponse.allHeaderFields.forEach { key, value in
                    print("   \(key): \(value)")
                }
                
                switch httpResponse.statusCode {
                case 200:
                    guard let tempURL = tempURL else {
                        print("❌ URL temporaire invalide")
                        promise(.failure(NetworkError.invalidResponse))
                        return
                    }
                    
                    do {
                        if FileManager.default.fileExists(atPath: destination.path) {
                            try FileManager.default.removeItem(at: destination)
                        }
                        try FileManager.default.moveItem(at: tempURL, to: destination)
                        print("✅ Fichier téléchargé avec succès")
                        promise(.success(destination))
                    } catch {
                        print("❌ Erreur lors du déplacement du fichier: \(error.localizedDescription)")
                        promise(.failure(NetworkError.networkError(error)))
                    }
                case 401:
                    print("❌ Non autorisé")
                    promise(.failure(NetworkError.unauthorized))
                case 404:
                    print("❌ Ressource non trouvée")
                    promise(.failure(NetworkError.serverError("Ressource non trouvée")))
                default:
                    print("❌ Erreur serveur: \(httpResponse.statusCode)")
                    promise(.failure(NetworkError.serverError("Erreur serveur: \(httpResponse.statusCode)")))
                }
            }
            
            // Configuration du suivi de progression
            let observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    progressHandler?(Float(progress.fractionCompleted))
                }
            }
            
            // Stockage de la tâche pour pouvoir l'annuler plus tard
            self.downloadTasks[urlString] = downloadTask
            
            downloadTask.resume()
            
            // Nettoyage de l'observation quand le téléchargement est terminé
            _ = observation
        }
        .handleEvents(receiveCancel: { [weak self] in
            self?.downloadTasks[urlString]?.cancel()
            self?.downloadTasks.removeValue(forKey: urlString)
        })
        .eraseToAnyPublisher()
    }
    
    func cancelDownload(for urlString: String) {
        downloadTasks[urlString]?.cancel()
        downloadTasks.removeValue(forKey: urlString)
    }
    
    func cancelAllDownloads() {
        downloadTasks.forEach { $0.value.cancel() }
        downloadTasks.removeAll()
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case serverError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .networkError(let error):
            return "Erreur réseau : \(error.localizedDescription)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Non autorisé"
        }
    }
} 