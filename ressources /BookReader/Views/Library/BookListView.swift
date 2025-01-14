import SwiftUI

struct BookListView: View {
    let books: [Book]
    let onDownload: (String) -> Void
    
    var body: some View {
        List {
            ForEach(books) { book in
                NavigationLink {
                    BookDetailView(book: book)
                } label: {
                    BookRowView(book: book, onDownload: {
                        onDownload(book.id)
                    })
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationView {
        BookListView(books: [
            Book(
                id: "1",
                title: "Le Petit Prince",
                author: "Antoine de Saint-Exupéry",
                description: "Un conte philosophique pour tous les âges",
                category: "Jeunesse",
                coverUrl: nil,
                isDownloaded: false,
                isNew: true
            )
        ], onDownload: { _ in })
    }
} 