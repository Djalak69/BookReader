import Foundation
import SwiftUI

// MARK: - API Response Models
struct AuthResponse: Codable {
    let token: String
    let user: User
}

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published var isRegistering = false
    @Published var isAuthenticated = false
    @Published private(set) var currentUser: User?
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var usernameError: String?
    
    // MARK: - Static Error Messages
    private static let emailRequiredMessage = "L'email est requis"
    private static let invalidEmailMessage = "L'email n'est pas valide"
    private static let passwordRequiredMessage = "Le mot de passe est requis"
    private static let usernameRequiredMessage = "Le nom d'utilisateur est requis"
    private static let weakPasswordMessage = "Le mot de passe doit contenir au moins 6 caractères"
    private static let loginErrorMessage = "Erreur lors de la connexion"
    private static let registerErrorMessage = "Erreur lors de l'inscription"
    private static let resetPasswordErrorMessage = "Erreur lors de la réinitialisation du mot de passe"
    private static let resetPasswordSuccessMessage = "Un email de réinitialisation a été envoyé"
    private static let emailAlreadyInUseMessage = "Cet email est déjà utilisé"
    private static let userNotFoundMessage = "Aucun utilisateur trouvé avec cet email"
    
    // MARK: - API Configuration
    private let baseURL = "https://bookreaderserver.onrender.com/api"
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
        
        // Vérifier si un token existe et restaurer la session
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            restoreSession(with: token)
        }
        
        // Log pour vérifier que l'API est accessible
        let testURL = URL(string: "https://bookreaderserver.onrender.com")!
        var request = URLRequest(url: testURL)
        request.httpMethod = "GET"
        
        print("Test de connexion à l'API...")
        session.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Erreur de connexion à l'API: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ API status: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        emailError == nil && passwordError == nil && 
        (!isRegistering || usernameError == nil) &&
        !email.isEmpty && !password.isEmpty &&
        (!isRegistering || !username.isEmpty)
    }
    
    // MARK: - Validation Methods
    func validateEmail() {
        emailError = nil
        guard !email.isEmpty else {
            emailError = Self.emailRequiredMessage
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = Self.invalidEmailMessage
        }
    }
    
    func validatePassword() {
        passwordError = nil
        guard !password.isEmpty else {
            passwordError = Self.passwordRequiredMessage
            return
        }
        
        if password.count < 6 {
            passwordError = Self.weakPasswordMessage
        }
    }
    
    func validateUsername() {
        usernameError = nil
        if isRegistering && username.isEmpty {
            usernameError = Self.usernameRequiredMessage
        }
    }
    
    // MARK: - Authentication Methods
    private func handleAuthResponse(_ authResponse: AuthResponse) {
        print("🔄 Début du traitement de la réponse d'authentification")
        print("📝 Token reçu: \(authResponse.token)")
        print("👤 Utilisateur reçu: \(authResponse.user.username)")
        
        UserDefaults.standard.set(authResponse.token, forKey: "authToken")
        print("💾 Token sauvegardé dans UserDefaults")
        
        Task { @MainActor in
            print("🔄 Mise à jour de l'état sur le thread principal")
            self.currentUser = authResponse.user
            print("👤 Utilisateur courant mis à jour: \(String(describing: self.currentUser?.username))")
            
            withAnimation {
                print("🔐 Mise à jour de l'état d'authentification à true")
                self.isAuthenticated = true
                print("✅ État final - isAuthenticated: \(self.isAuthenticated)")
            }
        }
    }
    
    func signIn() {
        Task {
            print("Tentative de connexion avec email: \(email)")
            isLoading = true
            error = nil
            
            let loginURL = URL(string: "\(baseURL)/auth/login")!
            var request = URLRequest(url: loginURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let body = ["email": email, "password": password]
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                print("Corps de la requête: \(String(data: jsonData, encoding: .utf8) ?? "")")
                
                print("Envoi de la requête à \(loginURL)")
                print("Headers: \(request.allHTTPHeaderFields ?? [:])")
                
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Réponse invalide")
                    self.error = Self.loginErrorMessage
                    return
                }
                
                print("Code de statut HTTP: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse du serveur: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                        print("Connexion réussie, token reçu")
                        await MainActor.run {
                            self.handleAuthResponse(authResponse)
                        }
                    } else {
                        print("Erreur de décodage de la réponse")
                        self.error = Self.loginErrorMessage
                    }
                } else if httpResponse.statusCode == 401 {
                    print("Identifiants invalides")
                    self.error = "Email ou mot de passe incorrect"
                } else {
                    print("Erreur serveur: \(httpResponse.statusCode)")
                    self.error = Self.loginErrorMessage
                }
            } catch {
                print("Erreur réseau: \(error.localizedDescription)")
                self.error = Self.loginErrorMessage
            }
            
            self.isLoading = false
        }
    }
    
    func signUp() {
        print("Tentative d'inscription avec email: \(email) et username: \(username)")
        isLoading = true
        error = nil
        
        let registerURL = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: registerURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["email": email, "password": password, "username": username]
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            print("Corps de la requête: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            print("Erreur d'encodage JSON: \(error)")
        }
        
        print("Envoi de la requête à \(registerURL)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Erreur réseau: \(error.localizedDescription)")
                    self?.error = Self.registerErrorMessage
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Réponse invalide")
                    self?.error = Self.registerErrorMessage
                    return
                }
                
                print("Code de statut HTTP: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse du serveur: \(responseString)")
                }
                
                if httpResponse.statusCode == 201 {
                    if let data = data,
                       let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                        print("Inscription réussie, token reçu")
                        self?.handleAuthResponse(authResponse)
                    } else {
                        print("Erreur de décodage de la réponse")
                        self?.error = Self.registerErrorMessage
                    }
                } else if httpResponse.statusCode == 409 {
                    print("Email déjà utilisé")
                    self?.error = Self.emailAlreadyInUseMessage
                } else {
                    print("Erreur serveur: \(httpResponse.statusCode)")
                    self?.error = Self.registerErrorMessage
                }
            }
        }.resume()
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            error = Self.emailRequiredMessage
            return
        }
        
        isLoading = true
        error = nil
        
        let resetURL = URL(string: "\(baseURL)/auth/reset-password")!
        var request = URLRequest(url: resetURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["email": email]
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            print("Corps de la requête: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            print("Erreur d'encodage JSON: \(error)")
        }
        
        print("Envoi de la requête à \(resetURL)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Erreur réseau: \(error.localizedDescription)")
                    self?.error = Self.resetPasswordErrorMessage
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Réponse invalide")
                    self?.error = Self.resetPasswordErrorMessage
                    return
                }
                
                print("Code de statut HTTP: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse du serveur: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    self?.error = Self.resetPasswordSuccessMessage
                } else if httpResponse.statusCode == 404 {
                    self?.error = Self.userNotFoundMessage
                } else {
                    print("Erreur serveur: \(httpResponse.statusCode)")
                    self?.error = Self.resetPasswordErrorMessage
                }
            }
        }.resume()
    }
    
    // MARK: - Session Management
    func restoreSession(with token: String) {
        // Vérifier la validité du token avec le serveur
        let verifyURL = URL(string: "\(baseURL)/auth/verify")!
        var request = URLRequest(url: verifyURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data),
                   (response as? HTTPURLResponse)?.statusCode == 200 {
                    self?.handleAuthResponse(authResponse)
                } else {
                    // Token invalide, déconnexion
                    self?.signOut()
                }
            }
        }.resume()
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        self.currentUser = nil
        self.isAuthenticated = false
        clearFields()
    }
    
    // MARK: - Helper Methods
    func clearFields() {
        email = ""
        password = ""
        username = ""
        error = nil
        emailError = nil
        passwordError = nil
        usernameError = nil
    }
    
    // MARK: - View State Management
    func toggleRegistration() {
        isRegistering.toggle()
        clearFields()
    }
}

