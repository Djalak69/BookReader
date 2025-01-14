import SwiftUI
import Combine

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Logo et titre
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
                            FormField(
                                title: "Nom d'utilisateur",
                                text: $viewModel.username,
                                error: viewModel.usernameError
                            )
                        }
                        
                        FormField(
                            title: "Email",
                            text: $viewModel.email,
                            error: viewModel.emailError,
                            keyboardType: .emailAddress
                        )
                        
                        FormField(
                            title: "Mot de passe",
                            text: $viewModel.password,
                            error: viewModel.passwordError,
                            isSecure: true
                        )
                        
                        if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            hideKeyboard()
                            if viewModel.isRegistering {
                                viewModel.signUp()
                            } else {
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
                        
                        Button {
                            hideKeyboard()
                            viewModel.toggleRegistration()
                        } label: {
                            Text(viewModel.isRegistering ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire")
                                .foregroundColor(.accentColor)
                        }
                        
                        if !viewModel.isRegistering {
                            Button("Mot de passe oublié ?") {
                                hideKeyboard()
                                viewModel.resetPassword()
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, keyboardHeight)
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                    keyboardHeight = keyboardFrame.height
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
        }
    }
}

private struct FormField: View {
    let title: String
    @Binding var text: String
    var error: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isSecure {
                SecureField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.done)
            } else {
                TextField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .submitLabel(.next)
            }
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}

// Extension pour masquer le clavier
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 