import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ArticleViewModel()
    
    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SavedArticlesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("My EW", systemImage: "person.crop.circle.fill")
                }
        }
        .environmentObject(viewModel)
        .onOpenURL { url in
            guard url.scheme == "etherworld" else { return }
            if url.host == "article" {
                let articleId = url.lastPathComponent
                NotificationManager.shared.selectedArticleId = articleId
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    ContentView()
}
