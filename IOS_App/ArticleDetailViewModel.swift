import Foundation
import Combine

final class ArticleDetailViewModel: ObservableObject {
    @Published var article: Article
    
    init(article: Article) {
        self.article = article
    }
}
