import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []
    @State private var sortOption: SortOption = .newest
    @State private var displayLimit: Int = 20
    @Environment(\.dismiss) private var dismiss

    private let ignoredTags: Set<String> = ["ew-promoted-top", "ew-promoted-bottom", "#ew-promoted-top", "#ew-promoted-bottom"]
    
    var allTags: [String] {
        // Count tag occurrences across all articles
        var tagCounts: [String: Int] = [:]
        for article in viewModel.articles {
            for tag in cleanTags(for: article) {
                tagCounts[tag, default: 0] += 1
            }
        }
        // Sort by frequency (most used first), then alphabetically
        return tagCounts.keys.sorted { lhs, rhs in
            let lCount = tagCounts[lhs] ?? 0
            let rCount = tagCounts[rhs] ?? 0
            if lCount != rCount {
                return lCount > rCount
            }
            return lhs < rhs
        }
    }

    var matchingAuthors: [AuthorResult] {
        guard !searchText.isEmpty, searchText.count >= 2 else { return [] }
        
        let searchWord = searchText.split(separator: " ").first.map(String.init) ?? searchText
        
        var seen = Set<String>()
        var authors: [AuthorResult] = []
        
        for article in viewModel.articles {
            guard let name = article.author, let slug = article.authorSlug else { continue }
            if seen.contains(slug) { continue }
            
            let firstName = name.split(separator: " ").first.map(String.init) ?? name
            if firstName.localizedCaseInsensitiveContains(searchWord) {
                seen.insert(slug)
                authors.append(AuthorResult(
                    name: name,
                    slug: slug,
                    profileImage: article.authorProfileImage
                ))
            }
        }
        
        return authors.sorted { $0.name < $1.name }
    }
    
    var filteredArticles: [Article] {
        var result = viewModel.articles
        
        if !searchText.isEmpty {
            result = result.filter { article in
                matchesSearch(article)
            }
        }
        
        if !selectedTags.isEmpty {
            let exactMatches = result.filter { article in
                let tags = Set(cleanTags(for: article))
                return selectedTags.allSatisfy { tags.contains($0) }
            }
            
            let partialMatches = result.filter { article in
                let tags = Set(cleanTags(for: article))
                return !selectedTags.allSatisfy { tags.contains($0) } &&
                selectedTags.contains(where: { tags.contains($0) })
            }
            
            var seen = Set<String>()
            result = (exactMatches + partialMatches).filter { article in
                if seen.contains(article.id) { return false }
                seen.insert(article.id)
                return true
            }
        }
        
        result.sort { lhs, rhs in
            let lScore = relevanceScore(for: lhs)
            let rScore = relevanceScore(for: rhs)
            if lScore != rScore { return lScore > rScore }
            switch sortOption {
            case .newest:
                return lhs.publishedAt > rhs.publishedAt
            case .oldest:
                return lhs.publishedAt < rhs.publishedAt
            case .author:
                return (lhs.author ?? "") < (rhs.author ?? "")
            }
        }
        
        return result
    }

    var paginatedArticles: [Article] {
        Array(filteredArticles.prefix(displayLimit))
    }

    private func loadMore() {
        displayLimit += 15
    }

    private func matchesSearch(_ article: Article) -> Bool {
        let searchWord = searchText.split(separator: " ").first.map(String.init) ?? searchText
        guard !searchWord.isEmpty else { return true }
        
        let contentMatches = article.contentHTML.localizedCaseInsensitiveContains(searchWord)
        let titleMatches = article.title.localizedCaseInsensitiveContains(searchWord)
        let excerptMatches = article.excerpt.localizedCaseInsensitiveContains(searchWord)
        let tagMatches = cleanTags(for: article).contains(where: { $0.localizedCaseInsensitiveContains(searchWord) })
        let authorMatches = article.author?.localizedCaseInsensitiveContains(searchWord) ?? false
        return titleMatches || excerptMatches || contentMatches || tagMatches || authorMatches
    }

    private func relevanceScore(for article: Article) -> Int {
        guard !searchText.isEmpty else { return 0 }
        let searchWord = searchText.split(separator: " ").first.map(String.init) ?? searchText
        guard !searchWord.isEmpty else { return 0 }
        
        var score = 0
        if article.title.localizedCaseInsensitiveContains(searchWord) { score += 6 }
        if article.excerpt.localizedCaseInsensitiveContains(searchWord) { score += 3 }
        if article.contentHTML.localizedCaseInsensitiveContains(searchWord) { score += 2 }
        if cleanTags(for: article).contains(where: { $0.localizedCaseInsensitiveContains(searchWord) }) { score += 4 }
        if article.author?.localizedCaseInsensitiveContains(searchWord) ?? false { score += 5 }
        if !selectedTags.isEmpty {
            let tags = Set(cleanTags(for: article))
            if selectedTags.allSatisfy({ tags.contains($0) }) {
                score += 5
            } else if selectedTags.contains(where: { tags.contains($0) }) {
                score += 2
            }
        }
        return score
    }

    private func cleanTags(for article: Article) -> [String] {
        article.tags.filter { tag in
            let normalizedTag = tag.lowercased().trimmingCharacters(in: .whitespaces)
            let tagWithoutHash = normalizedTag.hasPrefix("#") ? String(normalizedTag.dropFirst()) : normalizedTag
            return !ignoredTags.contains(tagWithoutHash) && !ignoredTags.contains(normalizedTag)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search articles or authors...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Sort and Tag Controls
                HStack {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.displayName)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortOption.displayName)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if !selectedTags.isEmpty {
                        Button {
                            selectedTags.removeAll()
                        } label: {
                            Text("Clear")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Tag Chips
                if !allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allTags.prefix(15), id: \.self) { tag in
                                TagChip(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                
                Divider()
                
                // Results
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading articles...")
                    Spacer()
                } else if !matchingAuthors.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Authors")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            VStack(spacing: 16) {
                                ForEach(matchingAuthors, id: \.slug) { author in
                                    NavigationLink(value: author.slug) {
                                        HStack(spacing: 12) {
                                            AsyncImage(url: author.profileImage) { phase in
                                                switch phase {
                                                case .empty:
                                                    Image(systemName: "person.crop.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundStyle(.secondary)
                                                case .success(let image):
                                                    image.resizable().scaledToFill()
                                                case .failure:
                                                    Image(systemName: "person.crop.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundStyle(.secondary)
                                                @unknown default:
                                                    Color.clear
                                                }
                                            }
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            
                                            Text(author.name)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if !filteredArticles.isEmpty {
                                Text("Articles")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                LazyVStack(spacing: 0) {
                                    ForEach(filteredArticles, id: \.id) { article in
                                        NavigationLink(value: article) {
                                            ArticleRowView(article: article)
                                        }
                                        .onAppear {
                                            if article.id == filteredArticles.last?.id {
                                                Task {
                                                    await viewModel.loadMore()
                                                }
                                            }
                                        }
                                    }
                                    
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .padding()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else if filteredArticles.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try different search terms or tags")
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredArticles, id: \.id) { article in
                                NavigationLink(value: article) {
                                    ArticleRowView(article: article)
                                }
                                .onAppear {
                                    // Load more when near the end
                                    if article.id == filteredArticles.last?.id {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .navigationDestination(for: String.self) { slug in
                AuthorProfileView(authorSlug: slug)
            }
        }
    }
}

struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

enum SortOption: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case author = "author"
    
    var displayName: String {
        switch self {
        case .newest: return "Newest First"
        case .oldest: return "Oldest First"
        case .author: return "By Author"
        }
    }
}

struct AuthorResult {
    let name: String
    let slug: String
    let profileImage: URL?
}

#Preview {
    DiscoverView()
}
