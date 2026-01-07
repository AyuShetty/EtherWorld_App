import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthorProfileViewModel: ObservableObject {
    @Published private(set) var author: Author?
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://etherworld.co"
    private let apiKey = "5b9aefe2ea7623b8fd81c52dec"
    
    func loadAuthor(slug: String) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch author details
            let authorURL = "\(baseURL)/ghost/api/v3/content/authors/slug/\(slug)/?key=\(apiKey)&include=count.posts"
            guard let url = URL(string: authorURL) else {
                throw NSError(domain: "Invalid URL", code: 0)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "Network Error", code: 0)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            struct GhostAuthorResponse: Codable {
                let authors: [GhostAuthor]
            }
            
            struct GhostAuthor: Codable {
                let id: String
                let name: String
                let slug: String
                let profile_image: String?
                let cover_image: String?
                let bio: String?
                let location: String?
                let website: String?
                let twitter: String?
                let facebook: String?
                let count: PostCount?
                
                struct PostCount: Codable {
                    let posts: Int
                }
            }
            
            let authorResponse = try decoder.decode(GhostAuthorResponse.self, from: data)
            
            if let ghostAuthor = authorResponse.authors.first {
                self.author = Author(
                    id: ghostAuthor.id,
                    name: ghostAuthor.name,
                    slug: ghostAuthor.slug,
                    profileImage: ghostAuthor.profile_image.flatMap { URL(string: $0) },
                    coverImage: ghostAuthor.cover_image.flatMap { URL(string: $0) },
                    bio: ghostAuthor.bio,
                    location: ghostAuthor.location,
                    website: ghostAuthor.website.flatMap { URL(string: $0) },
                    twitter: ghostAuthor.twitter,
                    facebook: ghostAuthor.facebook,
                    postCount: ghostAuthor.count?.posts
                )
                
                // Fetch author's articles
                await loadAuthorArticles(slug: slug)
            }
            
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to load author profile"
        }
    }
    
    private func loadAuthorArticles(slug: String) async {
        do {
            let articlesURL = "\(baseURL)/ghost/api/v3/content/posts/?key=\(apiKey)&filter=authors:\(slug)&include=authors,tags&fields=id,title,html,feature_image,published_at,reading_time"
            guard let url = URL(string: articlesURL) else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            struct GhostResponse: Codable {
                let posts: [GhostPost]
            }
            
            struct GhostAuthor: Codable {
                let name: String
                let slug: String
                let profile_image: String?
            }
            
            struct GhostTag: Codable {
                let name: String
            }
            
            struct GhostPost: Codable {
                let id: String
                let title: String
                let html: String
                let feature_image: String?
                let published_at: Date
                let reading_time: Int?
                let authors: [GhostAuthor]?
                let tags: [GhostTag]?
            }
            
            let response = try decoder.decode(GhostResponse.self, from: data)
            
            self.articles = response.posts.map { post in
                Article(
                    id: post.id,
                    title: post.title,
                    excerpt: post.html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).prefix(150) + "...",
                    contentHTML: post.html,
                    publishedAt: post.published_at,
                    url: "\(baseURL)/\(post.id)",
                    author: post.authors?.first?.name,
                    authorSlug: post.authors?.first?.slug,
                    authorProfileImage: post.authors?.first?.profile_image.flatMap { URL(string: $0) },
                    imageURL: post.feature_image.flatMap { URL(string: $0) },
                    tags: post.tags?.map { $0.name } ?? [],
                    readingTimeMinutes: post.reading_time
                )
            }
        } catch {
            // Articles failed to load, but keep the author profile
        }
    }
}
