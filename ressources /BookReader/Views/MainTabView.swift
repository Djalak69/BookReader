import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                Text("Bibliothèque")
                    .navigationTitle("Ma Bibliothèque")
            }
            .tabItem {
                Label("Bibliothèque", systemImage: "books.vertical")
            }
            
            NavigationView {
                Text("Rechercher")
                    .navigationTitle("Rechercher")
            }
            .tabItem {
                Label("Rechercher", systemImage: "magnifyingglass")
            }
            
            NavigationView {
                Text("Profil")
                    .navigationTitle("Mon Profil")
            }
            .tabItem {
                Label("Profil", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 