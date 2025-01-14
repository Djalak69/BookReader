import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Logo ou titre
                    VStack(spacing: 10) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("BookReader")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding(.top, 50)
                    
                    // Vue de connexion ou d'inscription
                    if viewModel.isRegistering {
                        RegisterView()
                    } else {
                        LoginView()
                    }
                    
                    // Bouton pour basculer entre connexion et inscription
                    Button(action: {
                        withAnimation {
                            viewModel.isRegistering.toggle()
                            viewModel.resetForm()
                        }
                    }) {
                        Text(viewModel.isRegistering ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire")
                            .foregroundColor(.accentColor)
                    }
                    
                    if !viewModel.isRegistering {
                        Button("Mot de passe oublié ?") {
                            viewModel.resetPassword()
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
} 