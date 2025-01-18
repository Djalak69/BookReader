import SwiftUI

@main
struct BookReaderApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if #available(macOS 13.0, *) {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                Text("Cette application nécessite macOS 13.0 ou une version plus récente")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    init() {
        #if DEBUG
        print("BookReader démarré en mode DEBUG")
        if let bundleId = Bundle.main.bundleIdentifier {
            print("Bundle ID: \(bundleId)")
        }
        #endif
        
        // Configuration de l'apparence
        #if os(iOS)
        UINavigationBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().tintColor = .systemBlue
        #else
        NSWindow.allowsAutomaticWindowTabbing = false
        #endif
    }
}

@available(macOS 13.0, *)
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                AuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    if #available(macOS 13.0, *) {
        ContentView()
            .environmentObject(AuthViewModel())
    } else {
        Text("Cette application nécessite macOS 13.0 ou une version plus récente")
    }
} 