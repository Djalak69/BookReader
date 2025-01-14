import Foundation

struct Book: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let author: String
    let description: String
    let category: String
    let coverUrl: URL?
    var isDownloaded: Bool
    let isNew: Bool
    
    // Pour Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Pour Equatable
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
} 