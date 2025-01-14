import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    // Formulaire
                    VStack(spacing: 20) {
                        if viewModel.isRegistering {
                            // Champ username pour l'inscription
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("Nom d'utilisateur", text: $viewModel.username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                
                                if let error = viewModel.usernameError {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            if let error = viewModel.emailError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            SecureField("Mot de passe", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if let error = viewModel.passwordError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        // Message d'erreur
                        if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        
                        // Bouton de connexion/inscription
                        Button(action: {
                            print("Bouton pressé")
                            if viewModel.isRegistering {
                                print("Tentative d'inscription...")
                                viewModel.signUp()
                            } else {
                                print("Tentative de connexion...")
                                viewModel.signIn()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(viewModel.isRegistering ? "S'inscrire" : "Se connecter")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .onChange(of: viewModel.isFormValid) { oldValue, newValue in
                            print("isFormValid changed to: \(newValue)")
                            print("email: \(viewModel.email)")
                            print("password: \(viewModel.password)")
                            print("emailError: \(String(describing: viewModel.emailError))")
                            print("passwordError: \(String(describing: viewModel.passwordError))")
                        }
                        
                        // Bouton pour basculer entre connexion et inscription
                        Button(action: {
                            withAnimation {
                                viewModel.isRegistering.toggle()
                                viewModel.error = nil
                                viewModel.email = ""
                                viewModel.password = ""
                                viewModel.username = ""
                                viewModel.emailError = nil
                                viewModel.passwordError = nil
                                viewModel.usernameError = nil
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
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
} 