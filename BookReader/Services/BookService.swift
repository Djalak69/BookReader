import Foundation

enum BookError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case authenticationRequired
}

class BookService {
    static let shared = BookService()
    private let baseURL = "https://bookreaderserver.onrender.com/api"
    private var authToken: String?
    
    private init() {
        print("BookService: Initialisé avec l'URL de base: \(baseURL)")
    }
    
    private func getFullURL(for path: String) -> String {
        if path.hasPrefix("http") {
            return path
        }
        let baseWithoutAPI = baseURL.replacingOccurrences(of: "/api", with: "")
        return baseWithoutAPI + path
    }
    
    private func createRequest(for url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
        print("BookService: Token d'authentification mis à jour")
    }
    
    // Récupérer tous les livres
    func fetchBooks() async throws -> [Book] {
        guard let url = URL(string: "\(baseURL)/books") else {
            print("BookService: URL invalide pour fetchBooks")
            throw BookError.invalidURL
        }
        
        print("BookService: Tentative de récupération des livres depuis: \(url)")
        
        let request = createRequest(for: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("BookService: Réponse invalide")
                throw BookError.invalidResponse
            }
            
            print("BookService: Statut de la réponse: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                throw BookError.authenticationRequired
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                print("BookService: Erreur serveur: \(errorMessage)")
                throw BookError.serverError(errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            var books = try decoder.decode([Book].self, from: data)
            
            // Correction des URLs relatives
            books = books.map { book in
                var modifiedBook = book
                if let coverUrl = book.coverUrl, !coverUrl.hasPrefix("http") {
                    modifiedBook = Book(
                        id: book.id,
                        title: book.title,
                        author: book.author,
                        description: book.description ?? "",
                        coverUrl: getFullURL(for: coverUrl),
                        epubUrl: getFullURL(for: book.epubUrl),
                        language: book.language,
                        publishDate: book.publishDate,
                        addedDate: book.addedDate,
                        isDownloaded: book.isDownloaded,
                        downloadCount: book.downloadCount,
                        readingProgress: book.readingProgress,
                        lastReadPosition: book.lastReadPosition,
                        category: book.category,
                        tags: book.tags,
                        isNew: book.isNew,
                        rating: book.rating,
                        pageCount: book.pageCount
                    )
                }
                return modifiedBook
            }
            
            print("BookService: \(books.count) livres récupérés avec succès")
            return books
            
        } catch let error as DecodingError {
            print("BookService: Erreur de décodage: \(error)")
            throw BookError.decodingError(error)
        } catch {
            print("BookService: Erreur réseau: \(error)")
            throw BookError.networkError(error)
        }
    }
    
    // Récupérer les livres par catégorie
    func fetchBooks(category: Book.BookCategory) async throws -> [Book] {
        guard let url = URL(string: "\(baseURL)/books?category=\(category.rawValue)") else {
            print("BookService: URL invalide pour fetchBooks avec catégorie: \(category.rawValue)")
            throw BookError.invalidURL
        }
        
        print("BookService: Tentative de récupération des livres pour la catégorie \(category.rawValue)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("BookService: Réponse invalide")
                throw BookError.invalidResponse
            }
            
            print("BookService: Statut de la réponse: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                print("BookService: Erreur serveur: \(errorMessage)")
                throw BookError.serverError(errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let books = try decoder.decode([Book].self, from: data)
            print("BookService: \(books.count) livres récupérés pour la catégorie \(category.rawValue)")
            return books
            
        } catch {
            print("BookService: Erreur lors de la récupération des livres par catégorie: \(error)")
            throw BookError.networkError(error)
        }
    }
    
    // Rechercher des livres
    func searchBooks(query: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/books/search?q=\(encodedQuery)") else {
            print("BookService: URL invalide pour la recherche: \(query)")
            throw BookError.invalidURL
        }
        
        print("BookService: Recherche de livres avec le terme: \(query)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("BookService: Réponse invalide")
                throw BookError.invalidResponse
            }
            
            print("BookService: Statut de la réponse: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                print("BookService: Erreur serveur: \(errorMessage)")
                throw BookError.serverError(errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let books = try decoder.decode([Book].self, from: data)
            print("BookService: \(books.count) livres trouvés pour la recherche: \(query)")
            return books
            
        } catch {
            print("BookService: Erreur lors de la recherche: \(error)")
            throw BookError.networkError(error)
        }
    }
    
    // Télécharger un livre
    func downloadBook(id: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/books/\(id)/download") else {
            print("BookService: URL invalide pour le téléchargement du livre: \(id)")
            throw BookError.invalidURL
        }
        
        print("BookService: Tentative de téléchargement du livre: \(id)")
        
        let request = createRequest(for: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("BookService: Réponse invalide")
                throw BookError.invalidResponse
            }
            
            print("BookService: Statut de la réponse: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                throw BookError.authenticationRequired
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                print("BookService: Erreur serveur: \(errorMessage)")
                throw BookError.serverError(errorMessage)
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(id).epub")
            try data.write(to: fileURL)
            
            print("BookService: Livre téléchargé avec succès: \(fileURL.path)")
            return fileURL
            
        } catch {
            print("BookService: Erreur lors du téléchargement: \(error)")
            throw BookError.networkError(error)
        }
    }
    
    // Mettre à jour la progression de lecture
    func updateReadingProgress(bookId: String, progress: Double) async throws {
        guard let url = URL(string: "\(baseURL)/books/\(bookId)/progress") else {
            print("BookService: URL invalide pour la mise à jour de la progression")
            throw BookError.invalidURL
        }
        
        print("BookService: Mise à jour de la progression pour le livre \(bookId): \(progress)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let progressData = ["progress": progress]
        request.httpBody = try JSONEncoder().encode(progressData)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("BookService: Réponse invalide")
                throw BookError.invalidResponse
            }
            
            print("BookService: Statut de la réponse: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                print("BookService: Erreur serveur: \(errorMessage)")
                throw BookError.serverError(errorMessage)
            }
            
            print("BookService: Progression mise à jour avec succès")
            
        } catch {
            print("BookService: Erreur lors de la mise à jour de la progression: \(error)")
            throw BookError.networkError(error)
        }
    }
} 