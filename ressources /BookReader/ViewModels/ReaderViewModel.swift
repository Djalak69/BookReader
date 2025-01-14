import Foundation
import Combine
import SwiftUI

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentChapter: String = ""
    @Published var fontSize: CGFloat = 16
    @Published var brightness: CGFloat = UIScreen.main.brightness
    @Published var theme: ReaderTheme = .light
    @Published var showSettings = false
    @Published var content: String = ""
    
    private let bookService = BookService.shared
    private var cancellables = Set<AnyCancellable>()
    
    let book: Book
    
    init(book: Book) {
        self.book = book
        setupObservers()
    }
    
    private func setupObservers() {
        // Observer pour sauvegarder la progression
        $currentPage
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] page in
                guard let self = self else { return }
                let progress = Double(page) / Double(max(self.totalPages, 1))
                Task {
                    await self.saveProgress(progress: progress)
                }
            }
            .store(in: &cancellables)
    }
    
    func loadBook() async {
        isLoading = true
        error = nil
        
        do {
            // Vérifier si le livre est déjà téléchargé
            guard book.isDownloaded else {
                // Télécharger le livre si nécessaire
                try await bookService.downloadBook(id: book.id)
                return // Sortir après le téléchargement pour recharger avec le livre téléchargé
            }
            
            // Simuler le chargement du contenu
            // TODO: Implémenter la lecture réelle du fichier ePub
            content = "Contenu temporaire du livre \(book.title)"
            totalPages = 10
            currentPage = Int(book.readingProgress * Double(totalPages))
            currentChapter = "Chapitre \(currentPage)"
            
        } catch {
            self.error = "Erreur lors du chargement du livre: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func saveProgress(progress: Double) async {
        do {
            try await bookService.updateReadingProgress(bookId: book.id, progress: progress)
        } catch {
            self.error = "Erreur lors de la sauvegarde de la progression: \(error.localizedDescription)"
        }
    }
    
    func nextPage() {
        guard currentPage < totalPages else { return }
        currentPage += 1
        currentChapter = "Chapitre \(currentPage)"
    }
    
    func previousPage() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        currentChapter = "Chapitre \(currentPage)"
    }
    
    func updateFontSize(_ size: CGFloat) {
        fontSize = size
    }
    
    func updateBrightness(_ value: CGFloat) {
        brightness = value
        UIScreen.main.brightness = value
    }
    
    func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }
}

enum ReaderTheme {
    case light
    case dark
    
    var backgroundColor: Color {
        switch self {
        case .light: return .white
        case .dark: return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }
} 