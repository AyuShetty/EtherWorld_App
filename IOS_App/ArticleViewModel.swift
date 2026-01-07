import Foundation
import SwiftUI
import Combine

@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service: ArticleService
    private let saveKey = "savedArticles"
    
    init(service: ArticleService = ServiceFactory.makeArticleService(environment: .production)) {
        self.service = service
        loadSavedState()
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await service.fetchArticles()
            self.articles = result.map { article in
                var mutableArticle = article
                mutableArticle.isSaved = isSaved(articleId: article.id)
                return mutableArticle
            }
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to load articles. Please try again."
        }
    }
    
    func toggleSaved(article: Article) {
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index].isSaved.toggle()
            saveSavedState()
        }
    }
    
    var savedArticles: [Article] {
        articles.filter { $0.isSaved }
    }
    
    private func isSaved(articleId: String) -> Bool {
        let saved = UserDefaults.standard.stringArray(forKey: saveKey) ?? []
        return saved.contains(articleId)
    }
    
    private func loadSavedState() {
        // Load saved article IDs from UserDefaults
        let saved = UserDefaults.standard.stringArray(forKey: saveKey) ?? []
        articles = articles.map { article in
            var mutableArticle = article
            mutableArticle.isSaved = saved.contains(article.id)
            return mutableArticle
        }
    }
    
    private func saveSavedState() {
        let savedIds = articles.filter { $0.isSaved }.map { $0.id }
        UserDefaults.standard.set(savedIds, forKey: saveKey)
    }
}
