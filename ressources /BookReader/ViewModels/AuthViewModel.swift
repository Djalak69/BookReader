import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var error: String?
    @Published var isAuthenticated = false
    @Published var isRegistering = false
    @Published var isLoading = false
    @Published var isFormValid = false
    
    @Published var username = ""
    @Published var usernameError: String?
    @Published var email = ""
    @Published var emailError: String?
    @Published var password = ""
    @Published var passwordError: String?
    
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
        checkAuthStatus()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest3($email, $password, $username)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.validateForm()
            }
            .store(in: &cancellables)
    }
    
    func signIn() {
        Task { @MainActor in
            self.isLoading = true
            defer { self.isLoading = false }
            
            do {
                let token = try await authService.login(email: email, password: password)
                self.isAuthenticated = true
                self.error = nil
            } catch AuthError.invalidCredentials {
                self.error = "Email ou mot de passe incorrect"
            } catch AuthError.serverError(let message) {
                self.error = message
            } catch {
                self.error = "Erreur de connexion: \(error.localizedDescription)"
            }
        }
    }
    
    func signUp() {
        Task { @MainActor in
            self.isLoading = true
            defer { self.isLoading = false }
            
            do {
                let token = try await authService.register(username: username, email: email, password: password)
                self.isAuthenticated = true
                self.error = nil
            } catch AuthError.serverError(let message) {
                self.error = message
            } catch {
                self.error = "Erreur d'inscription: \(error.localizedDescription)"
            }
        }
    }
    
    func resetPassword() {
        Task { @MainActor in
            self.isLoading = true
            defer { self.isLoading = false }
            
            do {
                try await authService.resetPassword(email: email)
                self.error = "Un email de réinitialisation a été envoyé"
            } catch {
                self.error = "Erreur de réinitialisation: \(error.localizedDescription)"
            }
        }
    }
    
    func logout() {
        authService.logout()
        self.isAuthenticated = false
        self.currentUser = nil
        resetForm()
    }
    
    func checkAuthStatus() {
        self.isAuthenticated = authService.checkAndRestoreToken()
    }
    
    func resetForm() {
        self.email = ""
        self.password = ""
        self.username = ""
        self.emailError = nil
        self.passwordError = nil
        self.usernameError = nil
        self.error = nil
    }
    
    private func validateForm() {
        validateEmail()
        validatePassword()
        if isRegistering {
            validateUsername()
        }
        
        isFormValid = emailError == nil && passwordError == nil && 
                     (!isRegistering || (isRegistering && usernameError == nil)) &&
                     !email.isEmpty && !password.isEmpty &&
                     (!isRegistering || (isRegistering && !username.isEmpty))
    }
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            emailError = "L'email est requis"
        } else if !emailPredicate.evaluate(with: email) {
            emailError = "Format d'email invalide"
        } else {
            emailError = nil
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Le mot de passe est requis"
        } else if password.count < 6 {
            passwordError = "Le mot de passe doit contenir au moins 6 caractères"
        } else {
            passwordError = nil
        }
    }
    
    private func validateUsername() {
        if username.isEmpty {
            usernameError = "Le nom d'utilisateur est requis"
        } else if username.count < 3 {
            usernameError = "Le nom d'utilisateur doit contenir au moins 3 caractères"
        } else {
            usernameError = nil
        }
    }
}

