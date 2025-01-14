import Foundation

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var selectedCategory: String?
    @Published var remainingDownloads: Int = 10
    @Published var isLoading = false
    @Published var error: String?
    
    var filteredBooks: [Book] {
        guard let category = selectedCategory, category != "Tous" else {
            return books
        }
        return books.filter { $0.category == category }
    }
    
    init() {
        Task {
            await loadBooks()
        }
    }
    
    func loadBooks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Implémenter l'appel API pour charger les livres
            // Pour l'instant, on utilise des données de test
            self.books = [
                Book(
                    id: "1",
                    title: "Le Petit Prince",
                    author: "Antoine de Saint-Exupéry",
                    description: "Un conte philosophique pour tous les âges",
                    category: "Jeunesse",
                    coverUrl: nil,
                    isDownloaded: false,
                    isNew: true
                ),
                Book(
                    id: "2",
                    title: "1984",
                    author: "George Orwell",
                    description: "Un roman d'anticipation dystopique",
                    category: "Science-fiction",
                    coverUrl: nil,
                    isDownloaded: false,
                    isNew: false
                )
            ]
        } catch {
            self.error = "Erreur lors du chargement des livres: \(error.localizedDescription)"
        }
    }
    
    func downloadBook(id: String) async {
        // TODO: Implémenter le téléchargement des livres
        guard let index = books.firstIndex(where: { $0.id == id }) else { return }
        books[index].isDownloaded = true
        remainingDownloads -= 1
    }
} 