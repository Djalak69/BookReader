import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // États du formulaire
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isRegistering = false
    
    // Validation des champs
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var usernameError: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        // Validation de l'email
        $email
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)
        
        // Validation du mot de passe
        $password
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
        
        // Validation du nom d'utilisateur
        $username
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] username in
                self?.validateUsername(username)
            }
            .store(in: &cancellables)
    }
    
    private func validateEmail(_ email: String) {
        print("Validation de l'email: \(email)")
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            print("Email vide")
            self.emailError = "L'email est requis"
        } else if !emailPredicate.evaluate(with: email) {
            print("Format d'email invalide")
            self.emailError = "Format d'email invalide"
        } else {
            print("Email valide")
            self.emailError = nil
        }
    }
    
    private func validatePassword(_ password: String) {
        print("Validation du mot de passe: \(password)")
        if password.isEmpty {
            print("Mot de passe vide")
            self.passwordError = "Le mot de passe est requis"
        } else if password.count < 8 {
            print("Mot de passe trop court")
            self.passwordError = "Le mot de passe doit contenir au moins 8 caractères"
        } else {
            print("Mot de passe valide")
            self.passwordError = nil
        }
    }
    
    private func validateUsername(_ username: String) {
        print("Validation du nom d'utilisateur: \(username)")
        if username.isEmpty && self.isRegistering {
            print("Nom d'utilisateur vide")
            self.usernameError = "Le nom d'utilisateur est requis"
        } else if username.count < 3 && self.isRegistering {
            print("Nom d'utilisateur trop court")
            self.usernameError = "Le nom d'utilisateur doit contenir au moins 3 caractères"
        } else {
            print("Nom d'utilisateur valide")
            self.usernameError = nil
        }
    }
    
    var isFormValid: Bool {
        print("Vérification de isFormValid")
        if isRegistering {
            print("Mode inscription - vérifiant email, password et username")
            return email.count >= 5 && password.count >= 6 && username.count >= 3 &&
                emailError == nil && passwordError == nil && usernameError == nil
        } else {
            print("Mode connexion - vérifiant email et password")
            print("Email length: \(email.count), Password length: \(password.count)")
            print("Email errors: \(String(describing: emailError))")
            print("Password errors: \(String(describing: passwordError))")
            return email.count >= 5 && password.count >= 6 &&
                emailError == nil && passwordError == nil
        }
    }
    
    // MARK: - Actions d'authentification
    
    @MainActor
    func signIn() {
        guard isFormValid else {
            print("Formulaire invalide, connexion impossible")
            return
        }
        
        isLoading = true
        print("Appel de l'API de connexion avec email: \(email)")
        
        // Simulation d'une connexion réussie
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            print("Connexion réussie pour l'utilisateur: \(self.email)")
        }
    }
    
    func signUp() {
        guard isFormValid else {
            self.error = "Veuillez remplir correctement tous les champs"
            return
        }
        
        Task {
            self.isLoading = true
            self.error = nil
            
            do {
                let (user, _) = try await APIService.shared.register(
                    email: email,
                    username: username,
                    password: password
                )
                self.currentUser = user
                self.isAuthenticated = true
                print("Inscription réussie pour l'utilisateur: \(user.username)")
            } catch let error as APIError {
                switch error {
                case .serverError(let message):
                    self.error = message
                case .networkError(_):
                    self.error = "Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet."
                default:
                    self.error = "Une erreur est survenue lors de l'inscription"
                }
                print("Erreur lors de l'inscription: \(error.message)")
            } catch {
                self.error = "Une erreur inattendue est survenue"
                print("Erreur inattendue lors de l'inscription: \(error)")
            }
            
            self.isLoading = false
        }
    }
    
    func signOut() {
        self.apiService.logout()
        self.currentUser = nil
        self.isAuthenticated = false
        self.email = ""
        self.password = ""
        self.username = ""
        self.error = nil
        self.emailError = nil
        self.passwordError = nil
        self.usernameError = nil
    }
    
    func resetPassword() {
        guard !self.email.isEmpty else {
            self.error = "Veuillez entrer votre email"
            return
        }
        
        guard self.emailError == nil else {
            self.error = "Veuillez entrer un email valide"
            return
        }
        
        Task {
            self.isLoading = true
            self.error = nil
            
            do {
                let message = try await self.apiService.resetPassword(email: self.email)
                self.error = message // Dans ce cas, nous utilisons error pour afficher le message de succès
            } catch let apiError as APIError {
                self.error = apiError.message
            } catch {
                self.error = "Une erreur inattendue s'est produite"
            }
            
            self.isLoading = false
        }
    }
    
    func refreshProfile() {
        Task {
            do {
                self.currentUser = try await self.apiService.getProfile()
            } catch {
                // Si nous ne pouvons pas rafraîchir le profil, nous déconnectons l'utilisateur
                self.signOut()
            }
        }
    }
}

