Tentative de connexion avec email: jshsys@usgsg.fr
Envoi de la requête à https://bookreader-api.onrender.com/api/auth/login
nw_resolver_start_query_timer_block_invoke [C1.1] Query fired: did not receive all answers in time for bookreader-api.onrender.com:443
Code de statut HTTP: 404
Réponse du serveur: Not Found

Erreur serveur: 404
nw_resolver_start_query_timer_block_invoke [C2] Query fired: did not receive all answers in time for bookreader-api.onrender.com:443import SwiftUI

@main
struct BookReaderApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

private struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
} 