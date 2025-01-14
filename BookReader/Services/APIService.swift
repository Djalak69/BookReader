import Foundation

class APIService {
    static let shared = APIService()
    
    func register(email: String, username: String, password: String) async throws -> (User, String) {
        // Implémentation de l'enregistrement
        let user = User(id: UUID().uuidString,
                       email: email,
                       username: username,
                       subscriptionStatus: nil,
                       downloadedBooks: 0,
                       profileImageUrl: nil)
        return (user, "Inscription réussie")
    }
    
    func resetPassword(email: String) async throws -> String {
        // Implémentation de la réinitialisation du mot de passe
        return "Un email de réinitialisation a été envoyé"
    }
    
    func getProfile() async throws -> User {
        // Implémentation pour obtenir le profil utilisateur
        return User(id: UUID().uuidString,
                   email: "test@example.com",
                   username: "Test User",
                   subscriptionStatus: nil,
                   downloadedBooks: 0,
                   profileImageUrl: nil)
    }
    
    func logout() {
        // Implémentation de la déconnexion
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
} 