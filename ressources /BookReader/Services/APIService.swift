import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func register(email: String, username: String, password: String) async throws -> (User, String) {
        // Implémentation de l'enregistrement
        let user = User(
            id: UUID().uuidString,
            username: username,
            email: email,
            preferences: User.UserPreferences(
                theme: "light",
                fontSize: 16,
                notifications: true
            )
        )
        
        return (user, "Inscription réussie")
    }
    
    func resetPassword(email: String) async throws -> String {
        // Implémentation de la réinitialisation du mot de passe
        return "Un email de réinitialisation a été envoyé"
    }
    
    func getProfile() async throws -> User {
        // Implémentation pour obtenir le profil utilisateur
        return User(
            id: UUID().uuidString,
            username: "Test User",
            email: "test@example.com",
            preferences: User.UserPreferences(
                theme: "light",
                fontSize: 16,
                notifications: true
            )
        )
    }
    
    func logout() {
        // Implémentation de la déconnexion
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
} 