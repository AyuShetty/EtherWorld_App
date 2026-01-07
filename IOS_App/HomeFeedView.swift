import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = ArticleViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading articles…")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Failed to load articles")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await viewModel.load() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if viewModel.articles.isEmpty {
                    ContentUnavailableView("No Articles", systemImage: "newspaper", description: Text("Check back later."))
                } else {
                    List(viewModel.articles) { article in
                        NavigationLink(value: article) {
                            ArticleRowView(article: article)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("EtherWorld")
            .task { await viewModel.load() }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }
}

#Preview {
    HomeFeedView()
}
