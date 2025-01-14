import SwiftUI

struct BookListView: View {
    let books: [Book] = [
        Book(id: "1", 
             title: "Sample Book 1", 
             author: "Author 1", 
             description: "Description 1", 
             coverUrl: nil, 
             epubUrl: "", 
             language: "fr", 
             publishDate: Date(), 
             addedDate: Date(), 
             isDownloaded: false, 
             downloadCount: 0, 
             readingProgress: 0.0, 
             lastReadPosition: 0,
             category: .fiction,
             tags: ["Roman", "Aventure"],
             isNew: true,
             rating: 4.5,
             pageCount: 300),
        Book(id: "2", 
             title: "Sample Book 2", 
             author: "Author 2", 
             description: "Description 2", 
             coverUrl: nil, 
             epubUrl: "", 
             language: "fr", 
             publishDate: Date(), 
             addedDate: Date(), 
             isDownloaded: false, 
             downloadCount: 0, 
             readingProgress: 0.0, 
             lastReadPosition: 0,
             category: .nonfiction,
             tags: ["Histoire", "Biographie"],
             isNew: false,
             rating: 4.0,
             pageCount: 250)
    ]

    var body: some View {
        NavigationView {
            List(books) { book in
                BookRowView(book: book)
            }
            .navigationTitle("Liste des Livres")
        }
    }
}

#Preview {
    BookListView()
} 