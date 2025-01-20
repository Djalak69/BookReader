import Foundation
import Models

@MainActor
class AddBookViewModel: ObservableObject {
    @Published var title = ""
    @Published var author = ""
    @Published var description = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false
    
    private let bookService: BookService
    
    init(bookService: BookService = BookService()) {
        self.bookService = bookService
    }
    
    func uploadBook(fileURL: URL) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let book = BookUpload(
                title: title,
                author: author,
                description: description,
                fileURL: fileURL
            )
            
            try await bookService.uploadBook(book)
            return true
        } catch {
            self.error = error
            self.showError = true
            return false
        }
    }
}

struct BookUpload {
    let title: String
    let author: String
    let description: String
    let fileURL: URL
}