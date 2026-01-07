import Foundation

struct GhostArticleService: ArticleService {
    enum ServiceError: Error {
        case invalidURL
        case networkError
        case decodingError
    }
    
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession
    
    init(baseURL: String = "https://etherworld.co", apiKey: String = "5b9aefe2ea7623b8fd81c52dec") {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = URLSession.shared
    }
    
    func fetchArticles() async throws -> [Article] {
        let urlString = "\(baseURL)/ghost/api/v3/content/posts/?key=\(apiKey)&include=authors,tags&fields=id,title,html,feature_image,published_at,reading_time"
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ServiceError.networkError
        }
        
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
        
        let ghostResponse = try decoder.decode(GhostResponse.self, from: data)
        return ghostResponse.posts.map { post in
            let coverImage = post.feature_image
            let authorName = post.authors?.first?.name
            let authorSlug = post.authors?.first?.slug
            let authorProfileImage = post.authors?.first?.profile_image
            let tagNames = post.tags?.map { $0.name } ?? []
            
            return Article(
                id: post.id,
                title: post.title,
                excerpt: post.html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).prefix(150) + "...",
                contentHTML: post.html,
                publishedAt: post.published_at,
                url: "\(baseURL)/\(post.id)",
                author: authorName,
                authorSlug: authorSlug,
                authorProfileImage: authorProfileImage.flatMap { URL(string: $0) },
                imageURL: coverImage.flatMap { URL(string: $0) },
                tags: tagNames,
                readingTimeMinutes: post.reading_time
            )
        }
        }
    }

