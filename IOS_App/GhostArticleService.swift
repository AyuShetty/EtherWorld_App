import Foundation

struct GhostArticleService: ArticleService {
    enum ServiceError: Error {
        case notConfigured
    }
    
    func fetchArticles() async throws -> [Article] {
        // TODO: Implement real Ghost API integration.
        // For now, throw to indicate not configured and allow swapping via ServiceFactory.
        throw ServiceError.notConfigured
    }
}
