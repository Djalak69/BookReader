import SwiftUI

struct BookListView: View {
    let books: [Book]
    let onDownload: (String) -> Void
    
    var body: some View {
        List {
            ForEach(books) { book in
                NavigationLink {
                    BookDetailView(book: book, from: .library)
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
                coverUrl: "https://example.com/cover.jpg",
                epubUrl: "https://example.com/book.epub",
                language: "fr",
                publishDate: Date(),
                addedDate: Date(),
                isDownloaded: false,
                downloadCount: 0,
                readingProgress: 0.0,
                lastReadPosition: 0,
                category: .children,
                tags: ["Classique", "Philosophie"],
                isNew: true,
                rating: 4.5,
                pageCount: 96
            )
        ], onDownload: { _ in })
    }
} 