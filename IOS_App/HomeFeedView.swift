import SwiftUI
import Combine

struct HomeFeedView: View {
    @EnvironmentObject var viewModel: ArticleViewModel
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingDiscover = false
    @State private var showingSettings = false
    @State private var navigationPath = NavigationPath()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ProgressView("Loading articles…")
                } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
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
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
            .navigationTitle("EtherWorld")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingDiscover = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingDiscover) {
                DiscoverView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .task {
                // Check for new articles and send notification if enabled
                if notificationsEnabled {
                    NotificationManager.shared.checkForNewArticles(articles: viewModel.articles)
                }
            }
            .onReceive(notificationManager.$selectedArticleId.compactMap { $0 }) { articleId in
                Task { await handleDeepLink(articleId: articleId) }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }

    private func handleDeepLink(articleId: String) async {
        // Ensure articles are loaded
        if viewModel.articles.isEmpty {
            await viewModel.load()
        }
        if let article = viewModel.articles.first(where: { $0.id == articleId }) {
            navigationPath.append(article)
            return
        }
        // Attempt a refresh if not found
        await viewModel.load()
        if let article = viewModel.articles.first(where: { $0.id == articleId }) {
            navigationPath.append(article)
        }
    }
}

#Preview {
    HomeFeedView()
}
