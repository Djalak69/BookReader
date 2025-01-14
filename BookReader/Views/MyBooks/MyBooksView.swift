import SwiftUI

struct MyBooksView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: BooksFilter = .all
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête avec filtres
                VStack(spacing: 10) {
                    HStack {
                        Text("Mes Livres")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        
                        Menu {
                            Button(action: {}) {
                                Label("Tout sélectionner", systemImage: "checkmark.circle")
                            }
                            Button(action: {}) {
                                Label("Trier par date", systemImage: "arrow.up.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    // Filtres
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(BooksFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Informations de stockage
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Stockage utilisé")
                            .font(.headline)
                        Text("1.2 GB sur 2 GB")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    CircularProgressView(progress: 0.6)
                        .frame(width: 40, height: 40)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Grille de livres
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 20) {
                    ForEach(0..<10) { _ in
                        DownloadedBookCard()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .bold()
        }
    }
}

struct DownloadedBookCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(2/3, contentMode: .fit)
                
                Menu {
                    Button(action: {}) {
                        Label("Supprimer", systemImage: "trash")
                    }
                    Button(action: {}) {
                        Label("Partager", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                    .lineLimit(2)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
    }
}

enum BooksFilter: CaseIterable {
    case all
    case recent
    case downloaded
    case favorites
    
    var title: String {
        switch self {
        case .all: return "Tous"
        case .recent: return "Récents"
        case .downloaded: return "Téléchargés"
        case .favorites: return "Favoris"
        }
    }
}

#Preview {
    MyBooksView()
        .environmentObject(AuthViewModel())
} 