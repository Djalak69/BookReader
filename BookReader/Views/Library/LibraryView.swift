import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedCategory: BookCategory = .all
    @State private var showSubscriptionInfo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête avec informations d'abonnement
                VStack(spacing: 15) {
                    HStack {
                        Text("Bibliothèque")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        
                        Button {
                            showSubscriptionInfo.toggle()
                        } label: {
                            Label("3 téléchargements restants", systemImage: "arrow.down.circle")
                                .font(.caption)
                                .padding(8)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(20)
                        }
                    }
                    
                    // Catégories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(BookCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.title,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Grille de livres
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 20) {
                    ForEach(0..<20) { _ in
                        LibraryBookCard()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showSubscriptionInfo) {
            SubscriptionInfoView()
        }
    }
}

struct CategoryChip: View {
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

struct LibraryBookCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(2/3, contentMode: .fit)
                
                Button {
                    // Action pour télécharger
                } label: {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .background(Circle().fill(.white))
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

struct SubscriptionInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Votre abonnement Premium")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .leading, spacing: 15) {
                    SubscriptionFeatureRow(icon: "book.fill", text: "Accès illimité à tous les livres")
                    SubscriptionFeatureRow(icon: "arrow.down.circle.fill", text: "3 téléchargements par mois")
                    SubscriptionFeatureRow(icon: "wifi", text: "Lecture hors-ligne disponible")
                    SubscriptionFeatureRow(icon: "bookmark.fill", text: "Synchronisation sur tous vos appareils")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SubscriptionFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(text)
                .font(.subheadline)
        }
    }
}

enum BookCategory: CaseIterable {
    case all
    case fiction
    case nonFiction
    case science
    case history
    case biography
    case poetry
    
    var title: String {
        switch self {
        case .all: return "Tous"
        case .fiction: return "Fiction"
        case .nonFiction: return "Non-Fiction"
        case .science: return "Science"
        case .history: return "Histoire"
        case .biography: return "Biographie"
        case .poetry: return "Poésie"
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(AuthViewModel())
} 