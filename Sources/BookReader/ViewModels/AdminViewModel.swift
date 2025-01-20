import Foundation
import Models

@MainActor
class AdminViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let bookService: BookService
    
    init(bookService: BookService = BookService()) {
        self.bookService = bookService
    }
    
    func loadBooks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            books = try await bookService.fetchBooks()
        } catch {
            self.error = error
        }
    }
    
    func deleteBook(_ book: Book) {
        Task {
            do {
                try await bookService.deleteBook(id: book.id)
                await loadBooks()
            } catch {
                self.error = error
            }
        }
    }
} 