import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SavedArticlesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
        }
        .environmentObject(viewModel)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
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
