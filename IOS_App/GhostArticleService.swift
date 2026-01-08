import Foundation

struct GhostArticleService: PaginatedArticleService {
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
        let config = URLSessionConfiguration.default
        // Aggressive HTTP caching for list payloads
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024, directory: nil)
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "Accept": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func fetchArticles() async throws -> [Article] {
        return try await fetchArticles(page: 1, limit: 50)
    }
    
    func fetchArticles(page: Int, limit: Int = 15) async throws -> [Article] {
        let urlString = "\(baseURL)/ghost/api/v3/content/posts/?key=\(apiKey)&include=authors,tags&fields=id,title,html,feature_image,published_at,reading_time&page=\(page)&limit=\(limit)&order=published_at%20desc"
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

    // Fetch full content HTML for a specific article by id on demand
    func fetchArticleContent(id: String) async throws -> String {
        let urlString = "\(baseURL)/ghost/api/v3/content/posts/\(id)/?key=\(apiKey)&fields=html"
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ServiceError.networkError
        }
        struct SinglePostResponse: Codable { let posts: [GhostPost] }
        let decoder = JSONDecoder()
        let single = try decoder.decode(SinglePostResponse.self, from: data)
        return single.posts.first?.html ?? ""
    }
}

