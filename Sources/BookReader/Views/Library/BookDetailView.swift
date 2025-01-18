import SwiftUI
import Models

struct BookDetailView: View {
    let book: Book
    @State private var showReader = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image de couverture
                AsyncImage(url: book.coverURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 300)
                
                // Informations du livre
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let author = book.author {
                        Text(author)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if let description = book.description {
                        Text(description)
                            .padding(.top)
                    }
                }
                .padding()
                
                // Bouton Lire
                Button(action: { showReader = true }) {
                    Text("Lire")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showReader) {
            ReaderView(bookTitle: book.title)
        }
    }
}

#Preview {
    BookDetailView(book: Book(
        id: "1",
        title: "Le Petit Prince",
        author: "Antoine de Saint-Exupéry",
        description: "Un livre sur un petit prince qui voyage à travers les étoiles.",
        coverURL: URL(string: "https://example.com/cover.jpg"),
        downloadURL: URL(string: "https://example.com/book.epub")
    ))
} 