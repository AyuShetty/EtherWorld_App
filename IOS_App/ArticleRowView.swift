import SwiftUI

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image
            if let imageURL = article.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(ProgressView())
                }
            }
            
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
            
            if let author = article.author, let authorSlug = article.authorSlug {
                NavigationLink(destination: AuthorProfileView(authorSlug: authorSlug)) {
                    HStack(spacing: 8) {
                        if let profileImage = article.authorProfileImage {
                            CachedAsyncImage(url: profileImage) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 24, height: 24)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 24, height: 24)
                        }
                        
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Article: \(article.title). Author: \(article.author ?? "Unknown author").")
    }
}

#Preview {
    NavigationStack {
        ArticleRowView(article: Article(
            id: "1",
            title: "Sample Title",
            excerpt: "Short excerpt for preview purposes.",
            contentHTML: "<p>Content</p>",
            publishedAt: .now,
            url: "https://example.com",
            author: "Preview",
            authorSlug: "preview",
            authorProfileImage: nil,
            imageURL: nil,
            tags: ["Swift"],
            readingTimeMinutes: 5
        ))
        .padding()
    }
}
