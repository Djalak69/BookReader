import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Accueil", systemImage: "house.fill")
            }
            
            NavigationStack {
                MyBooksView()
            }
            .tabItem {
                Label("Mes Livres", systemImage: "books.vertical.fill")
            }
            
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label("Bibliothèque", systemImage: "building.columns.fill")
            }
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Rechercher", systemImage: "magnifyingglass")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 