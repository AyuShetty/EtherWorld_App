import Foundation

struct Author: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let slug: String
    let profileImage: URL?
    let coverImage: URL?
    let bio: String?
    let location: String?
    let website: URL?
    let twitter: String?
    let facebook: String?
    let postCount: Int?
}
