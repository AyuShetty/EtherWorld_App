import Foundation

protocol ArticleService {
    func fetchArticles() async throws -> [Article]
}
