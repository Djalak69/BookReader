import Foundation

public enum UserRole: String, Codable {
    case user
    case admin
}

public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String?
    public let role: UserRole
    
    public init(id: String, email: String, name: String? = nil, role: UserRole = .user) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
    }
} 