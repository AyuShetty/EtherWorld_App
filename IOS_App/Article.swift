import Foundation

struct Article: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let excerpt: String
    let contentHTML: String
    let publishedAt: Date
    let url: String
    let author: String?
    let authorSlug: String?
    let authorProfileImage: URL?
    let imageURL: URL?
    let tags: [String]
    let readingTimeMinutes: Int?
    var isSaved: Bool = false
}