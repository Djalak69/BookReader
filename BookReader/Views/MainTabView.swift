import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            MyBooksView()
                .tabItem {
                    Label("Mes Livres", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            LibraryView()
                .tabItem {
                    Label("Bibliothèque", systemImage: "building.columns.fill")
                }
                .tag(2)
            
            SearchView()
                .tabItem {
                    Label("Rechercher", systemImage: "magnifyingglass")
                }
                .tag(3)
        }
        .tint(.purple) // Couleur d'accent personnalisée
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 