import Foundation
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedCategory: Book.BookCategory?
    @Published var searchQuery = ""
    @Published var remainingDownloads: Int = 3
    @Published var showLoginAlert = false
    @Published var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    private let bookService = BookService.shared
    
    init() {
        // Vérifier s'il y a un token sauvegardé
        AuthService.shared.checkAndRestoreToken()
        setupSearchSubscription()
        Task {
            await loadBooks()
        }
    }
    
    private func setupSearchSubscription() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    Task { [weak self] in
                        await self?.searchBooks(query: query)
                    }
                } else {
                    Task { [weak self] in
                        await self?.loadBooks()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadBooks() async {
        isLoading = true
        error = nil
        
        do {
            if let category = selectedCategory {
                books = try await bookService.fetchBooks(category: category)
            } else {
                books = try await bookService.fetchBooks()
            }
        } catch BookError.authenticationRequired {
            showLoginAlert = true
            self.error = "Authentification requise"
        } catch let err {
            self.error = err.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchBooks(query: String) async {
        guard !query.isEmpty else {
            await loadBooks()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            books = try await bookService.searchBooks(query: query)
        } catch {
            self.error = "Erreur lors de la recherche: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func downloadBook(id: String) async {
        do {
            _ = try await bookService.downloadBook(id: id)
            // Mettre à jour le livre dans la liste
            if let index = books.firstIndex(where: { $0.id == id }),
               let bookToUpdate = books[safe: index] {
                // Créer une nouvelle instance du livre avec les valeurs mises à jour
                let updatedBook = Book(
                    id: bookToUpdate.id,
                    title: bookToUpdate.title,
                    author: bookToUpdate.author,
                    description: bookToUpdate.description ?? "",
                    coverUrl: bookToUpdate.coverUrl,
                    epubUrl: bookToUpdate.epubUrl,
                    language: bookToUpdate.language,
                    publishDate: bookToUpdate.publishDate,
                    addedDate: bookToUpdate.addedDate,
                    isDownloaded: true, // Mettre à jour isDownloaded
                    downloadCount: bookToUpdate.downloadCount + 1, // Incrémenter downloadCount
                    readingProgress: bookToUpdate.readingProgress,
                    lastReadPosition: bookToUpdate.lastReadPosition,
                    category: bookToUpdate.category,
                    tags: bookToUpdate.tags,
                    isNew: bookToUpdate.isNew,
                    rating: bookToUpdate.rating,
                    pageCount: bookToUpdate.pageCount
                )
                // Remplacer le livre dans le tableau
                books[index] = updatedBook
            }
        } catch BookError.authenticationRequired {
            showLoginAlert = true
            self.error = "Authentification requise pour télécharger"
        } catch let err {
            self.error = "Erreur lors du téléchargement: \(err.localizedDescription)"
        }
    }
    
    @MainActor
    func login(email: String, password: String) async -> Bool {
        do {
            let token = try await AuthService.shared.login(email: email, password: password)
            isAuthenticated = true
            await loadBooks() // Recharger les livres après la connexion
            return true
        } catch {
            self.error = "Erreur de connexion: \(error.localizedDescription)"
            return false
        }
    }
    
    func logout() {
        AuthService.shared.logout()
        isAuthenticated = false
        books = []
        error = nil
    }
    
    func updateCategory(_ category: Book.BookCategory?) {
        selectedCategory = category
        Task {
            await loadBooks()
        }
    }
    
    func updateReadingProgress(bookId: String, progress: Double) async {
        do {
            try await bookService.updateReadingProgress(bookId: bookId, progress: progress)
        } catch {
            self.error = "Erreur lors de la mise à jour de la progression: \(error.localizedDescription)"
        }
    }
} 