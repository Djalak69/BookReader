import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isRegistering = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var error: Error?
    @Published var currentUser: User?
    
    // Champs du formulaire
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }
    
    func login() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.login(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            error = nil
        } catch {
            self.error = error
            showError = true
        }
    }
    
    func register() async {
        guard validateRegistration() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.register(
                email: email,
                password: password,
                name: name
            )
            currentUser = user
            isAuthenticated = true
            error = nil
        } catch {
            self.error = error
            showError = true
        }
    }
    
    func signOut() {
        authService.signOut()
        isAuthenticated = false
        currentUser = nil
        clearForm()
    }
    
    private func validateRegistration() -> Bool {
        guard !email.isEmpty else {
            error = ValidationError.emptyEmail
            showError = true
            return false
        }
        
        guard !password.isEmpty else {
            error = ValidationError.emptyPassword
            showError = true
            return false
        }
        
        guard password == confirmPassword else {
            error = ValidationError.passwordMismatch
            showError = true
            return false
        }
        
        return true
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        error = nil
        showError = false
    }
}

enum ValidationError: LocalizedError {
    case emptyEmail
    case emptyPassword
    case passwordMismatch
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "L'email est requis"
        case .emptyPassword:
            return "Le mot de passe est requis"
        case .passwordMismatch:
            return "Les mots de passe ne correspondent pas"
        }
    }
} 