import SwiftUI

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            HStack(spacing: 16) {
                // Couverture du livre
                if let coverUrl = book.coverUrl, let url = URL(string: coverUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 90)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 90)
                        .overlay(
                            Image(systemName: "book.fill")
                                .foregroundColor(.gray)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Informations du livre
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Barre de progression si le livre est téléchargé
                    if book.isDownloaded {
                        ProgressView(value: book.readingProgress, total: 1.0)
                            .progressViewStyle(.linear)
                            .frame(height: 2)
                            .tint(.purple)
                    }
                }
                
                Spacer()
                
                // Indicateurs d'état
                VStack(alignment: .trailing, spacing: 4) {
                    if book.isNew {
                        Text("Nouveau")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                    
                    if book.isDownloaded {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", book.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    NavigationView {
        List {
            BookRowView(book: Book(
                id: "1",
                title: "Le Titre du Livre Qui Peut Être Long",
                author: "Nom de l'Auteur",
                description: "Description",
                coverUrl: nil,
                epubUrl: "",
                language: "fr",
                publishDate: Date(),
                addedDate: Date(),
                isDownloaded: true,
                downloadCount: 1,
                readingProgress: 0.45,
                lastReadPosition: 0,
                category: .fiction,
                tags: ["Fantasy"],
                isNew: true,
                rating: 4.5,
                pageCount: 300
            ))
        }
    }
} 