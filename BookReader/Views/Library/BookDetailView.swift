import SwiftUI

enum BookSource {
    case library
    case search
}

struct BookDetailView: View {
    let book: Book
    let from: BookSource
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image de couverture
                if let coverUrlString = book.coverUrl,
                   let coverUrl = URL(string: coverUrlString) {
                    AsyncImage(url: coverUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 300)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Titre et auteur
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // Badges
                    HStack {
                        if book.isNew {
                            Badge(text: "Nouveau", color: .blue)
                        }
                        Badge(text: book.category.rawValue, color: .purple)
                    }
                    
                    // Description
                    Text("À propos de ce livre")
                        .font(.headline)
                        .padding(.top)
                    
                    if let description = book.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !book.isDownloaded {
                Button(action: {
                    // TODO: Action de téléchargement
                }) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BookDetailView(
            book: Book(
                id: "1",
                title: "Le Petit Prince",
                author: "Antoine de Saint-Exupéry",
                description: "Dans ce conte poétique et philosophique, un aviateur tombé en panne dans le désert rencontre un mystérieux petit prince venu des étoiles. À travers les conversations et les récits de ce petit prince, Saint-Exupéry livre une réflexion profonde sur la vie, l'amour, l'amitié et la société moderne.",
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
            ),
            from: .library
        )
    }
} 