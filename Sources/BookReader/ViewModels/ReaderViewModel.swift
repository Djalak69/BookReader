import SwiftUI
import Models

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let epubService: EPUBService
    let book: Book
    
    init(book: Book, epubService: EPUBService = EPUBService()) {
        self.book = book
        self.epubService = epubService
    }
    
    func loadBook() async {
        guard let url = book.downloadURL else {
            error = NSError(domain: "BookReader", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL de téléchargement manquante"])
            return
        }
        
        isLoading = true
        
        do {
            content = try await epubService.downloadAndLoadBook(url: url)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 