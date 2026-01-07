import SwiftUI

struct SavedArticlesView: View {
    @StateObject private var viewModel = ArticleViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedArticles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Saved Articles")
                            .font(.headline)
                        Text("Save articles to read them offline")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    List(viewModel.savedArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            HStack(alignment: .top, spacing: 12) {
                                if let imageURL = article.imageURL {
                                    AsyncImage(url: imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .empty, .failure:
                                            Color.gray.opacity(0.2)
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(8)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(article.title)
                                        .font(.headline)
                                        .lineLimit(2)
                                    
                                    Text(article.excerpt)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        if let author = article.author {
                                            Text(author)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(article.publishedAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.toggleSaved(article: article)
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Saved")
        }
        .onAppear {
            Task {
                await viewModel.load()
            }
        }
    }
}

#Preview {
    SavedArticlesView()
}
