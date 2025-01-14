import Foundation

struct User: Codable {
    let id: String
    let email: String
    let username: String
    let subscriptionStatus: String?
    let downloadedBooks: Int?
    let profileImageUrl: String?
} 