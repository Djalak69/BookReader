import SwiftUI

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

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            print("🔍 ContentView apparaît")
            print("🔑 État d'authentification initial: \(authViewModel.isAuthenticated)")
            if let user = authViewModel.currentUser {
                print("👤 Utilisateur connecté: \(user.username)")
            } else {
                print("👤 Aucun utilisateur connecté")
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { newValue in
            print("⚡️ Changement d'état d'authentification: \(newValue)")
            if newValue {
                print("✅ Navigation vers MainTabView")
            } else {
                print("❌ Navigation vers AuthView")
            }
        }
    }
} 