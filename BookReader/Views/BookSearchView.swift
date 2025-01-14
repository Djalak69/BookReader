import SwiftUI

struct BookSearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Rechercher un livre", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    // Exemple de résultats de recherche
                    ForEach(0..<10) { index in
                        Text("Résultat \(index)")
                    }
                }
            }
            .navigationTitle("Recherche")
        }
    }
}

#Preview {
    BookSearchView()
} 