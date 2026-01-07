import Foundation

struct ServiceFactory {
    enum Environment {
        case mock
        case production
    }
    
    static func makeArticleService(environment: Environment = .production) -> ArticleService {
        switch environment {
        case .mock:
            return MockArticleService()
        case .production:
            return GhostArticleService()
        }
    }
}
