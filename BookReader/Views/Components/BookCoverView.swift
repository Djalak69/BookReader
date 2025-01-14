import SwiftUI

struct BookCoverView: View {
    let coverUrl: URL?
    
    var body: some View {
        Group {
            if let coverUrl = coverUrl {
                AsyncImage(url: coverUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "book.closed")
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(width: 80, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    BookCoverView(coverUrl: nil)
        .padding()
} 