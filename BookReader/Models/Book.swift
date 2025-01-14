import Foundation

struct Book: Identifiable, Codable {
    let id: String
    let title: String
    let author: String
    let description: String?
    let coverUrl: String?
    let epubUrl: String
    let language: String
    let publishDate: Date
    let addedDate: Date
    let isDownloaded: Bool
    let downloadCount: Int
    var readingProgress: Double
    var lastReadPosition: Int
    var category: BookCategory
    var tags: [String]
    var isNew: Bool
    var rating: Double
    var pageCount: Int
    
    enum BookCategory: String, Codable, CaseIterable {
        case fiction = "Fiction"
        case nonfiction = "Non-fiction"
        case poetry = "Poésie"
        case comics = "BD & Mangas"
        case children = "Jeunesse"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case author
        case description
        case coverUrl = "coverUrl"
        case epubUrl = "epubUrl"
        case language
        case publishDate
        case addedDate
        case isDownloaded
        case downloadCount
        case readingProgress
        case lastReadPosition
        case category
        case tags
        case isNew
        case rating
        case pageCount
    }
    
    private static let dateFormatters: [DateFormatter] = {
        // ISO8601
        let iso8601Formatter = DateFormatter()
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // Format simple
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        
        // Format avec heure
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return [iso8601Formatter, simpleFormatter, fullFormatter]
    }()
    
    private static func parseDate(_ dateString: String) -> Date? {
        for formatter in dateFormatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Décodage des champs obligatoires
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        
        // Décodage des champs optionnels avec valeurs par défaut
        description = try container.decodeIfPresent(String.self, forKey: .description)
        coverUrl = try container.decodeIfPresent(String.self, forKey: .coverUrl)
        epubUrl = try container.decodeIfPresent(String.self, forKey: .epubUrl) ?? ""
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "fr"
        
        // Gestion des dates
        if let publishDateString = try container.decodeIfPresent(String.self, forKey: .publishDate) {
            publishDate = Book.parseDate(publishDateString) ?? Date()
        } else {
            publishDate = try container.decodeIfPresent(Date.self, forKey: .publishDate) ?? Date()
        }
        
        if let addedDateString = try container.decodeIfPresent(String.self, forKey: .addedDate) {
            addedDate = Book.parseDate(addedDateString) ?? Date()
        } else {
            addedDate = try container.decodeIfPresent(Date.self, forKey: .addedDate) ?? Date()
        }
        
        // Décodage des autres champs avec valeurs par défaut
        isDownloaded = try container.decodeIfPresent(Bool.self, forKey: .isDownloaded) ?? false
        downloadCount = try container.decodeIfPresent(Int.self, forKey: .downloadCount) ?? 0
        readingProgress = try container.decodeIfPresent(Double.self, forKey: .readingProgress) ?? 0.0
        lastReadPosition = try container.decodeIfPresent(Int.self, forKey: .lastReadPosition) ?? 0
        category = try container.decodeIfPresent(BookCategory.self, forKey: .category) ?? .fiction
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0.0
        pageCount = try container.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
    }
    
    // Initialisation manuelle pour la prévisualisation et les tests
    init(id: String, title: String, author: String, description: String, coverUrl: String?, epubUrl: String, language: String, publishDate: Date, addedDate: Date, isDownloaded: Bool, downloadCount: Int, readingProgress: Double, lastReadPosition: Int, category: BookCategory, tags: [String], isNew: Bool, rating: Double, pageCount: Int) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.coverUrl = coverUrl
        self.epubUrl = epubUrl
        self.language = language
        self.publishDate = publishDate
        self.addedDate = addedDate
        self.isDownloaded = isDownloaded
        self.downloadCount = downloadCount
        self.readingProgress = readingProgress
        self.lastReadPosition = lastReadPosition
        self.category = category
        self.tags = tags
        self.isNew = isNew
        self.rating = rating
        self.pageCount = pageCount
    }
} 