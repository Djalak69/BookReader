import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Section "Continuer la lecture"
                    ContinueReadingSection()
                    
                    // Section "Les Incontournables"
                    FeaturedBooksSection()
                    
                    // Section "Nouveautés"
                    NewReleasesSection()
                    
                    // Section "Pour vous"
                    RecommendedSection()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Accueil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action pour le profil
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

// Section "Continuer la lecture"
struct ContinueReadingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continuer la lecture")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        ContinueReadingCard()
                    }
                }
            }
        }
    }
}

// Carte pour "Continuer la lecture"
struct ContinueReadingCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 220)
                
                // Indicateur de progression
                ProgressView(value: 0.45)
                    .frame(width: 140)
                    .padding(.bottom, 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(width: 160)
        }
    }
}

// Section "Les Incontournables"
struct FeaturedBooksSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Les Incontournables")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        BookCard()
                    }
                }
            }
        }
    }
}

// Section "Nouveautés"
struct NewReleasesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nouveautés")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        BookCard()
                    }
                }
            }
        }
    }
}

// Section "Pour vous"
struct RecommendedSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pour vous")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        BookCard()
                    }
                }
            }
        }
    }
}

// Carte de livre générique
struct BookCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 180)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                    .lineLimit(2)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(width: 120)
        }
    }
}

#Preview {
    HomeView()
} 