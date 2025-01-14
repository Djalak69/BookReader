import SwiftUI

struct BookDetailView: View {
    let book: Book
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image de couverture
                if let coverUrl = book.coverUrl {
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
                        Badge(text: book.category, color: .purple)
                    }
                    
                    // Description
                    Text("À propos de ce livre")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(book.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
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
        BookDetailView(book: Book(
            id: "1",
            title: "Le Petit Prince",
            author: "Antoine de Saint-Exupéry",
            description: "Dans ce conte poétique et philosophique, un aviateur tombé en panne dans le désert rencontre un mystérieux petit prince venu des étoiles. À travers leurs conversations et les récits des voyages du petit prince, Saint-Exupéry livre une réflexion profonde sur la vie, l'amour, l'amitié et la société moderne.",
            category: "Jeunesse",
            coverUrl: nil,
            isDownloaded: false,
            isNew: true
        ))
    }
} 