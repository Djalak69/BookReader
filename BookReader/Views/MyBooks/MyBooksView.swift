import SwiftUI

struct MyBooksView: View {
    @State private var selectedFilter: BookFilter = .all
    @State private var searchText = ""
    
    enum BookFilter: String, CaseIterable {
        case all = "Tous"
        case reading = "En lecture"
        case finished = "Terminés"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(BookFilter.allCases, id: \.self) { filter in
                            FilterButton(filter: filter, selectedFilter: $selectedFilter)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Liste des livres
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 24) {
                        ForEach(0..<10) { _ in
                            DownloadedBookCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Mes Livres")
            .searchable(text: $searchText, prompt: "Rechercher dans mes livres")
        }
    }
}

struct FilterButton: View {
    let filter: MyBooksView.BookFilter
    @Binding var selectedFilter: MyBooksView.BookFilter
    
    var body: some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedFilter == filter ? Color.purple : Color.gray.opacity(0.1))
                )
                .foregroundColor(selectedFilter == filter ? .white : .primary)
        }
    }
}

struct DownloadedBookCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Couverture du livre
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(2/3, contentMode: .fit)
                
                // Indicateur de téléchargement
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.green)
                    .background(Circle().fill(.white))
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                // Barre de progression
                ProgressView(value: 0.45)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
                
                Text("45%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    MyBooksView()
} 