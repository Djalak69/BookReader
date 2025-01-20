import SwiftUI

@available(macOS 13.0, *)
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("Rechercher", systemImage: "magnifyingglass")
                }
            
            LibraryView()
                .tabItem {
                    Label("Bibliothèque", systemImage: "books.vertical.fill")
                }
            
            if authViewModel.currentUser?.role == .admin {
                AdminView()
                    .tabItem {
                        Label("Administration", systemImage: "gear")
                    }
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
}

#Preview {
    if #available(macOS 13.0, *) {
        MainTabView()
            .environmentObject(AuthViewModel())
    } else {
        Text("Cette application nécessite macOS 13.0 ou une version plus récente")
    }
} 