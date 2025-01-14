import SwiftUI
import OSLog

struct SearchBarView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher un livre, un auteur...", text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button {
                    withAnimation {
                        text = ""
                        isFocused = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .transition(.opacity)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SearchView: View {
    private let logger = Logger(subsystem: "com.bookreader.app", category: "SearchView")
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(text: $viewModel.searchText)
                    .padding()
                
                List {
                    if viewModel.searchText.isEmpty {
                        suggestionsSection
                        categoriesSection
                    } else {
                        Group {
                            if viewModel.isLoading {
                                loadingSection
                            } else if let error = viewModel.error {
                                errorSection(error: error)
                            } else {
                                resultsSection
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Rechercher")
            .navigationDestination(for: String.self) { category in
                Text(category)
                    .navigationTitle(category)
            }
            .navigationDestination(for: SearchResult.self) { result in
                Text(result.title)
                    .navigationTitle(result.title)
            }
            .safeToolbar {
                Button(action: {
                    viewModel.showFilters = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.accentColor)
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FilterView(viewModel: viewModel)
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    // Annuler les tâches en cours si l'app passe en arrière-plan
                    viewModel.cancelSearch()
                }
            }
        }
    }
    
    private var loadingSection: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }
        }
    }
    
    private func errorSection(error: Error) -> some View {
        Section {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundColor(.red)
                Text("Une erreur est survenue")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    private var suggestionsSection: some View {
        Section(header: Text("Suggestions")) {
            ForEach(viewModel.suggestedSearches, id: \.self) { suggestion in
                Button(action: {
                    viewModel.searchText = suggestion
                }) {
                    Text(suggestion)
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        Section(header: Text("Catégories populaires")) {
            ForEach(viewModel.popularCategories, id: \.self) { category in
                NavigationLink(value: category) {
                    Text(category)
                }
            }
        }
    }
    
    private var resultsSection: some View {
        Section {
            if viewModel.searchResults.isEmpty {
                HStack {
                    Spacer()
                    Text("Aucun résultat trouvé")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                ForEach(viewModel.searchResults) { result in
                    NavigationLink(value: result) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.author)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

extension View {
    func safeToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                content()
            }
        }
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(SearchFilter.allCases, id: \.self) { filter in
                Button {
                    viewModel.selectedFilter = filter
                    dismiss()
                } label: {
                    HStack {
                        Text(filter.title)
                        Spacer()
                        if viewModel.selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .foregroundColor(.primary)
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
        .presentationDetents([.medium])
    }
}

#Preview {
    SearchView()
} 