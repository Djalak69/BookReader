import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            TextField("Rechercher un livre...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List {
                // Ici nous ajouterons plus tard la logique de recherche
                Text("Résultats de recherche apparaîtront ici")
            }
        }
    }
}

#Preview {
    SearchView()
} 