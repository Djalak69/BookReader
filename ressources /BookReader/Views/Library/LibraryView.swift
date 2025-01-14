import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Bannière d'abonnement
                SubscriptionBannerView(remainingDownloads: viewModel.remainingDownloads)
                    .padding(.horizontal)
                
                // Filtres par catégorie
                CategoryFiltersView(selectedCategory: $viewModel.selectedCategory)
                
                // Liste des livres
                BookListView(books: viewModel.filteredBooks) { bookId in
                    Task {
                        await viewModel.downloadBook(id: bookId)
                    }
                }
            }
            .navigationTitle("Bibliothèque")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Erreur", isPresented: .constant(viewModel.error != nil)) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    LibraryView()
} 