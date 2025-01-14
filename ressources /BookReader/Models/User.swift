import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    var preferences: UserPreferences
    
    struct UserPreferences: Codable {
        var theme: String
        var fontSize: Int
        var notifications: Bool
        
        static let `default` = UserPreferences(
            theme: "light",
            fontSize: 16,
            notifications: true
        )
    }
    
    static let mock = User(
        id: "mock-id",
        username: "Utilisateur Test",
        email: "test@example.com",
        preferences: UserPreferences.default
    )
} 