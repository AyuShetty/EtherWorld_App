import Foundation
import SwiftUI
import Combine

@MainActor
final class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var hasMoreArticles: Bool = true
    @Published var errorMessage: String?
    
    private let service: ArticleService
    private let saveKey = "savedArticles"
    private var currentPage: Int = 1
    private let pageSize: Int = 15
    
    init(service: ArticleService = ServiceFactory.makeArticleService(environment: .production)) {
        self.service = service
        loadSavedState()
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1
        hasMoreArticles = true
        defer { isLoading = false }
        do {
            let result = try await service.fetchArticles()
            self.articles = result.map { article in
                var mutableArticle = article
                mutableArticle.isSaved = isSaved(articleId: article.id)
                return mutableArticle
            }
            self.errorMessage = nil
            // Check if we got fewer than expected (means no more pages)
            if result.count < pageSize {
                hasMoreArticles = false
            }
        } catch {
            self.errorMessage = "Failed to load articles. Please try again."
        }
    }
    
    func loadMore() async {
        guard !isLoadingMore, !isLoading, hasMoreArticles else { return }
        guard let ghostService = service as? GhostArticleService else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        currentPage += 1
        do {
            let result = try await ghostService.fetchArticles(page: currentPage, limit: pageSize)
            if result.isEmpty {
                hasMoreArticles = false
            } else {
                let newArticles = result.map { article in
                    var mutableArticle = article
                    mutableArticle.isSaved = isSaved(articleId: article.id)
                    return mutableArticle
                }
                // Filter out duplicates
                let existingIds = Set(articles.map { $0.id })
                let uniqueNew = newArticles.filter { !existingIds.contains($0.id) }
                articles.append(contentsOf: uniqueNew)
                
                if result.count < pageSize {
                    hasMoreArticles = false
                }
            }
        } catch {
            currentPage -= 1 // Revert on error
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
