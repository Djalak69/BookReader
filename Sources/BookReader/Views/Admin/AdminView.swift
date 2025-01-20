import SwiftUI
import Models
import UniformTypeIdentifiers

struct AdminView: View {
    @StateObject private var viewModel = AdminViewModel()
    @State private var showingFilePicker = false
    @State private var showingAddBookSheet = false
    @State private var selectedFileURL: URL?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { showingFilePicker = true }) {
                        Label("Ajouter un livre", systemImage: "plus.circle.fill")
                    }
                }
                
                Section("Livres disponibles") {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(viewModel.books) { book in
                            BookRow(book: book) {
                                viewModel.deleteBook(book)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Administration")
            .refreshable {
                await viewModel.loadBooks()
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType(filenameExtension: "epub")!],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFileURL = url
                        showingAddBookSheet = true
                    }
                case .failure(let error):
                    print("Erreur lors de la sélection du fichier: \(error.localizedDescription)")
                }
            }
            .sheet(isPresented: $showingAddBookSheet) {
                if let url = selectedFileURL {
                    AddBookView(fileURL: url) { success in
                        if success {
                            Task {
                                await viewModel.loadBooks()
                            }
                        }
                        showingAddBookSheet = false
                    }
                }
            }
        }
    }
}

struct BookRow: View {
    let book: Book
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AdminView()
} 