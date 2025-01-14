import Foundation
import SwiftUI
import Combine
import OSLog

@MainActor
class SearchViewModel: ObservableObject {
    private let logger = Logger(subsystem: "com.bookreader.app", category: "SearchViewModel")
    private let searchQueue = DispatchQueue(label: "com.bookreader.searchQueue", qos: .userInitiated)
    
    @Published var searchText = "" {
        willSet {
            if newValue.isEmpty && !searchText.isEmpty {
                Task { @MainActor in
                    searchResults = []
                    isLoading = false
                    error = nil
                }
                searchTask?.cancel()
                searchTask = nil
            }
        }
    }
    
    @Published var selectedFilter: SearchFilter = .all
    @Published var showFilters = false
    @Published private(set) var searchResults: [SearchResult] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var searchTask: Task<Void, Never>?
    private var searchCancellable: AnyCancellable?
    
    let suggestedSearches = [
        "Science-fiction",
        "Romans policiers",
        "Fantasy",
        "Développement personnel",
        "Histoire"
    ]
    
    let popularCategories = [
        "Bestsellers",
        "Nouveautés",
        "Prix littéraires",
        "Classiques",
        "Jeunesse",
        "Business"
    ]
    
    init() {
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        searchCancellable = $searchText
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: searchQueue)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.searchTask?.cancel()
                self?.searchTask = Task { [weak self] in
                    await self?.performSearch(text)
                }
            }
    }
    
    @MainActor
    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        if isLoading {
            isLoading = false
        }
    }
    
    private func performSearch(_ query: String) async {
        guard !Task.isCancelled else { return }
        
        do {
            await MainActor.run {
                isLoading = true
                error = nil
            }
            
            try await Task.sleep(for: .milliseconds(100))
            guard !Task.isCancelled else { return }
            
            let newResults = (0..<5).map { index in
                SearchResult(
                    id: UUID(),
                    title: "Livre \(index + 1) pour '\(query)'",
                    author: "Auteur \(index + 1)"
                )
            }
            
            guard !Task.isCancelled else { return }
            await MainActor.run {
                searchResults = newResults
                isLoading = false
            }
            
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.error = error
                self.searchResults = []
                isLoading = false
            }
        }
    }
    
    deinit {
        searchCancellable?.cancel()
        Task { @MainActor in
            searchTask?.cancel()
            searchTask = nil
        }
    }
}

struct SearchResult: Identifiable, Hashable {
    let id: UUID
    let title: String
    let author: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

enum SearchFilter: CaseIterable {
    case all
    case title
    case author
    case category
    
    var title: String {
        switch self {
        case .all: return "Tous"
        case .title: return "Titre"
        case .author: return "Auteur"
        case .category: return "Catégorie"
        }
    }
} 