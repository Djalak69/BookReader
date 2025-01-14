import SwiftUI

struct BookRowView: View {
    let book: Book
    let onDownload: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            BookCoverView(coverUrl: book.coverUrl)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(book.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if book.isNew {
                    Badge(text: String(localized: "book.new"), color: .blue)
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
            category: "Jeunesse",
            coverUrl: nil,
            isDownloaded: false,
            isNew: true
        ),
        onDownload: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
} 