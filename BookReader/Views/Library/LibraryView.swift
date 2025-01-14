import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var showSubscriptionInfo = false
    @State private var showLoginSheet = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Bannière d'abonnement et téléchargements restants
                SubscriptionBanner(remainingDownloads: viewModel.remainingDownloads)
                    .padding()
                
                // Catégories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button {
                            viewModel.updateCategory(nil)
                        } label: {
                            Text("Tout")
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.selectedCategory == nil ? Color.purple : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(viewModel.selectedCategory == nil ? .white : .primary)
                        }
                        
                        ForEach(Book.BookCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.updateCategory(category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Réessayer") {
                            Task {
                                await viewModel.loadBooks()
                            }
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    // Grille de livres
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20),
                        ], spacing: 24) {
                            ForEach(viewModel.books) { book in
                                LibraryBookCard(
                                    book: book,
                                    remainingDownloads: viewModel.remainingDownloads
                                ) { bookId in
                                    Task {
                                        await viewModel.downloadBook(id: bookId)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Bibliothèque")
            .searchable(text: $viewModel.searchQuery, prompt: "Rechercher un livre")
            .alert("Authentification requise", isPresented: $viewModel.showLoginAlert) {
                Button("Se connecter") {
                    showLoginSheet = true
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Vous devez vous connecter pour accéder à cette fonctionnalité.")
            }
            .sheet(isPresented: $showLoginSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Connexion")) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Mot de passe", text: $password)
                                .textContentType(.password)
                        }
                        
                        if let error = viewModel.error {
                            Section {
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                Task {
                                    isLoggingIn = true
                                    if await viewModel.login(email: email, password: password) {
                                        showLoginSheet = false
                                        email = ""
                                        password = ""
                                    }
                                    isLoggingIn = false
                                }
                            }) {
                                if isLoggingIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Text("Se connecter")
                                }
                            }
                            .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                        }
                    }
                    .navigationTitle("Connexion")
                    .navigationBarItems(trailing: Button("Annuler") {
                        showLoginSheet = false
                    })
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: Book.BookCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct LibraryBookCard: View {
    let book: Book
    let remainingDownloads: Int
    let onDownload: (String) -> Void
    
    @State private var isDownloading = false
    @State private var showDownloadAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Couverture
            ZStack(alignment: .bottomTrailing) {
                if let coverUrl = book.coverUrl, let url = URL(string: coverUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(2/3, contentMode: .fit)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay(
                            Image(systemName: "book.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                // Bouton de téléchargement
                Button {
                    if remainingDownloads > 0 {
                        withAnimation {
                            isDownloading = true
                        }
                        onDownload(book.id)
                        // La fin du téléchargement sera gérée par le ViewModel
                    } else {
                        showDownloadAlert = true
                    }
                } label: {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Group {
                                if isDownloading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                } else {
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.purple)
                                }
                            }
                        )
                }
                .padding(8)
            }
            
            // Informations du livre
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                // Tags
                HStack {
                    Text(book.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .clipShape(Capsule())
                    
                    if book.isNew {
                        Text("Nouveau")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .alert("Limite de téléchargement atteinte", isPresented: $showDownloadAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Vous avez atteint votre limite de téléchargements pour ce mois-ci. Les téléchargements seront réinitialisés le mois prochain.")
        }
    }
}

#Preview {
    LibraryView()
} 