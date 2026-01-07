import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(article.title)
                    .font(.title)
                    .bold()
                Text(article.excerpt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                Text(article.contentHTML)
                    .font(.body)
                    .textSelection(.enabled)
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: Article(
            id: "1",
            title: "Sample Title",
            excerpt: "Short excerpt for preview purposes.",
            contentHTML: "<p>Full content</p>",
            publishedAt: .now,
            url: "https://example.com",
            author: "Preview",
            imageURL: nil,
            tags: ["Swift"],
            readingTimeMinutes: 5
        ))
    }
}
