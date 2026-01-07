import SwiftUI

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(article.excerpt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRowView(article: Article(
        id: "1",
        title: "Sample Title",
        excerpt: "Short excerpt for preview purposes.",
        contentHTML: "<p>Content</p>",
        publishedAt: .now,
        url: "https://example.com",
        author: "Preview",
        imageURL: nil,
        tags: ["Swift"],
        readingTimeMinutes: 5
    ))
    .padding()
}
