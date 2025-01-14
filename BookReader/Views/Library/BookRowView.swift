import SwiftUI

struct BookRowView: View {
    let book: Book
    let onDownload: () -> Void
    
    var body: some View {
        HStack {
            // Couverture du livre
            if let coverUrlString = book.coverUrl,
               let coverUrl = URL(string: coverUrlString) {
                AsyncImage(url: coverUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 80)
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 80)
                        .cornerRadius(8)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "book.closed")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if book.isNew {
                        Badge(text: String(localized: "book.new"), color: .blue)
                    }
                    Badge(text: book.category.rawValue, color: .purple)
                }
            }
            
            Spacer(minLength: 16)
            
            DownloadButton(isDownloaded: book.isDownloaded, action: onDownload)
        }
        .padding()
    }
}

#Preview {
    BookRowView(
        book: Book(
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
        ),
        onDownload: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
} 