import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilter = .all
    @State private var showFilters = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Barre de recherche personnalisée
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Rechercher un livre, un auteur...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                
                if searchText.isEmpty {
                    // Suggestions
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Suggestions")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(suggestedSearches, id: \.self) { suggestion in
                                    SuggestionChip(text: suggestion) {
                                        searchText = suggestion
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Catégories populaires
                        Text("Catégories populaires")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(popularCategories, id: \.self) { category in
                                CategoryCard(category: category)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Résultats de recherche
                    LazyVStack(spacing: 15) {
                        ForEach(0..<10) { _ in
                            SearchResultRow()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            SearchFiltersView(selectedFilter: $selectedFilter)
        }
    }
    
    let suggestedSearches = [
        "Science-fiction",
        "Romans policiers",
        "Fantasy",
        "Développement personnel",
        "Histoire"
    ]
    
    let popularCategories = [
        "Bestsellers",
        "Nouveautés",
        "Prix littéraires",
        "Classiques",
        "Jeunesse",
        "Business"
    ]
}

struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.primary)
                .cornerRadius(20)
        }
    }
}

struct CategoryCard: View {
    let category: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SearchResultRow: View {
    var body: some View {
        HStack(spacing: 15) {
            // Couverture du livre
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 90)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Description courte du livre qui peut tenir sur plusieurs lignes...")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SearchFiltersView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFilter: SearchFilter
    
    var body: some View {
        NavigationView {
            List {
                ForEach(SearchFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                        dismiss()
                    } label: {
                        HStack {
                            Text(filter.title)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Filtres")
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

enum SearchFilter: CaseIterable {
    case all
    case title
    case author
    case category
    
    var title: String {
        switch self {
        case .all: return "Tous"
        case .title: return "Titre"
        case .author: return "Auteur"
        case .category: return "Catégorie"
        }
    }
}

#Preview {
    SearchView()
} 