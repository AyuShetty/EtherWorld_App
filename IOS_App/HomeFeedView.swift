import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @State private var showingDiscover = false
    @State private var showingSettings = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
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
                await viewModel.load()
                // Check for new articles and send notification if enabled
                if notificationsEnabled {
                    NotificationManager.shared.checkForNewArticles(articles: viewModel.articles)
                }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }
}

#Preview {
    HomeFeedView()
}
