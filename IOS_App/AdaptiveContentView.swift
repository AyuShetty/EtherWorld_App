import SwiftUI

struct AdaptiveContentView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @StateObject private var authManager = AuthenticationManager()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: NavigationTab = .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    
    enum NavigationTab: String, CaseIterable {
        case home = "Home"
        case search = "Search"
        case saved = "Saved"
        case profile = "My EW"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .saved: return "bookmark.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad: NavigationSplitView with sidebar
                iPadLayout
            } else {
                // iPhone: TabView
                iPhoneLayout
            }
        }
        .environmentObject(viewModel)
        .environmentObject(authManager)
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
    
    @ViewBuilder
    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                ForEach(NavigationTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .listRowBackground(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                }
            }
            .navigationTitle("EtherWorld")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            // Detail view based on selection
            Group {
                switch selectedTab {
                case .home:
                    HomeFeedView()
                case .search:
                    DiscoverView()
                case .saved:
                    SavedArticlesView()
                case .profile:
                    ProfileSettingsView()
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(NavigationTab.home)
            
            DiscoverView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(NavigationTab.search)
            
            SavedArticlesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(NavigationTab.saved)
            
            ProfileSettingsView()
                .tabItem {
                    Label("My EW", systemImage: "person.crop.circle.fill")
                }
                .tag(NavigationTab.profile)
        }
    }
}

#Preview {
    AdaptiveContentView()
}
