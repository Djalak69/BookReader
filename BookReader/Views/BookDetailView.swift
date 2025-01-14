import SwiftUI

struct BookDetailView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var showReader = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête avec couverture et informations principales
                HStack(alignment: .top, spacing: 20) {
                    // Couverture du livre
                    if let coverUrl = book.coverUrl, let url = URL(string: coverUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(2/3, contentMode: .fit)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                )
                        }
                        .frame(width: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 5)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 140)
                            .aspectRatio(2/3, contentMode: .fit)
                            .overlay(
                                Image(systemName: "book.fill")
                                    .foregroundColor(.gray)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Informations principales
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title2)
                            .bold()
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(book.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", book.rating))
                                .foregroundColor(.secondary)
                        }
                        
                        if book.isDownloaded {
                            Label("Téléchargé", systemImage: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Boutons d'action
                HStack(spacing: 20) {
                    if book.isDownloaded {
                        Button {
                            showReader = true
                        } label: {
                            Label("Lire", systemImage: "book.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    } else {
                        Button {
                            // Action de téléchargement
                        } label: {
                            Label("Télécharger", systemImage: "arrow.down.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    
                    Button {
                        // Action pour ajouter aux favoris
                    } label: {
                        Label("Favoris", systemImage: "heart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                }
                .padding(.horizontal)
                
                // Informations détaillées
                VStack(alignment: .leading, spacing: 16) {
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("À propos de ce livre")
                            .font(.title3)
                            .bold()
                        
                        if let description = book.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Aucune description disponible")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Divider()
                    
                    // Détails techniques
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informations")
                            .font(.title3)
                            .bold()
                        
                        DetailRow(title: "Catégorie", value: book.category.rawValue)
                        DetailRow(title: "Langue", value: book.language.uppercased())
                        DetailRow(title: "Pages", value: "\(book.pageCount)")
                        DetailRow(title: "Date de publication", value: formatDate(book.publishDate))
                        if !book.tags.isEmpty {
                            DetailRow(title: "Tags", value: book.tags.joined(separator: ", "))
                        }
                    }
                    
                    if book.isDownloaded && book.readingProgress > 0 {
                        Divider()
                        
                        // Progression de lecture
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progression")
                                .font(.title3)
                                .bold()
                            
                            ProgressView(value: book.readingProgress, total: 1.0)
                                .tint(.purple)
                            
                            Text("\(Int(book.readingProgress * 100))% lu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReader) {
            // Vue du lecteur à implémenter
            Text("Reader View")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationView {
        BookDetailView(book: Book(
            id: "1",
            title: "Sample Book",
            author: "Author Name",
            description: "Description du livre qui peut être assez longue et contenir plusieurs lignes de texte pour tester l'affichage.",
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
            tags: ["Fantasy", "Adventure"],
            isNew: true,
            rating: 4.5,
            pageCount: 300
        ))
    }
} 