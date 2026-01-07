import Foundation
import SwiftUI

@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service: ArticleService
    
    init(service: ArticleService = ServiceFactory.makeArticleService(environment: .mock)) {
        self.service = service
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await service.fetchArticles()
            self.articles = result
            self.errorMessage = nil
        } catch {
            self.errorMessage = String(describing: error)
        }
    }
}
