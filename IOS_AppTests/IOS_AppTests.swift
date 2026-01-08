//
//  IOS_AppTests.swift
//  IOS_AppTests
//
//  Created by Ayush Shetty on 05/01/26.
//

import Testing
@testable import IOS_App

struct IOS_AppTests {

    @Test func pagination_dedupes_and_stops_on_empty_page() async {
        let service = MockPagingService()
        let viewModel = ArticleViewModel(service: service)
        await viewModel.load()
        #expect(viewModel.articles.count == 2)
        #expect(viewModel.hasMoreArticles == true)
        
        await viewModel.loadMore()
        #expect(viewModel.articles.count == 3) // article2 deduped, article3 added
        #expect(viewModel.hasMoreArticles == true)
        
        await viewModel.loadMore()
        #expect(viewModel.hasMoreArticles == false)
    }


private final class MockPagingService: PaginatedArticleService {
    private let pages: [[Article]] = [
        [Article(id: "1", title: "A", excerpt: "", contentHTML: "", publishedAt: .now, url: "u1", author: nil, authorSlug: nil, authorProfileImage: nil, imageURL: nil, tags: [], readingTimeMinutes: nil),
         Article(id: "2", title: "B", excerpt: "", contentHTML: "", publishedAt: .now, url: "u2", author: nil, authorSlug: nil, authorProfileImage: nil, imageURL: nil, tags: [], readingTimeMinutes: nil)],
        [Article(id: "2", title: "B2", excerpt: "", contentHTML: "", publishedAt: .now, url: "u2", author: nil, authorSlug: nil, authorProfileImage: nil, imageURL: nil, tags: [], readingTimeMinutes: nil),
         Article(id: "3", title: "C", excerpt: "", contentHTML: "", publishedAt: .now, url: "u3", author: nil, authorSlug: nil, authorProfileImage: nil, imageURL: nil, tags: [], readingTimeMinutes: nil)],
        []
    ]
    
    func fetchArticles() async throws -> [Article] {
        try await fetchArticles(page: 1, limit: 15)
    }
    
    func fetchArticles(page: Int, limit: Int) async throws -> [Article] {
        let idx = max(0, page - 1)
        return idx < pages.count ? pages[idx] : []
    }
}
}
