import SwiftUI
import Models

struct ReaderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReaderViewModel
    
    init(book: Book) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        Text(viewModel.content)
                            .padding()
                    }
                }
            }
            .navigationTitle(viewModel.book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .task {
            await viewModel.loadBook()
        }
        .alert("Erreur", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ReaderView(book: Book(
        id: "1",
        title: "Mon Livre",
        author: "Auteur",
        description: "Description",
        coverURL: nil,
        downloadURL: URL(string: "https://example.com/book.epub")
    ))
} 