import SwiftUI

struct AuthorProfileView: View {
    let authorSlug: String
    @StateObject private var viewModel = AuthorProfileViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading profile...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Failed to load profile")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await viewModel.loadAuthor(slug: authorSlug) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let author = viewModel.author {
                VStack(spacing: 0) {
                    // Cover Image
                    if let coverImage = author.coverImage {
                        CachedAsyncImage(url: coverImage) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                                .frame(height: 200)
                        }
                    }
                    
                    // Profile Section
                    VStack(spacing: 16) {
                        // Profile Image
                        if let profileImage = author.profileImage {
                            CachedAsyncImage(url: profileImage) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            }
                            .offset(y: -60)
                            .padding(.bottom, -60)
                        }
                        
                        // Author Info
                        VStack(spacing: 8) {
                            Text(author.name)
                                .font(.title)
                                .bold()
                            
                            if let location = author.location {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle")
                                        .font(.caption)
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let website = author.website {
                                Link(destination: website) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                            .font(.caption)
                                        Text(website.absoluteString)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        
                        // Social Links
                        HStack(spacing: 16) {
                            if let twitter = author.twitter {
                                Link(destination: URL(string: "https://twitter.com/\(twitter)")!) {
                                    HStack {
                                        Image(systemName: "bird")
                                        Text("Twitter")
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                            
                            if let postCount = author.postCount {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("\(postCount) posts")
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        
                        if let bio = author.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Articles Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("STORIES BY \(author.name.uppercased())")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.teal)
                            .cornerRadius(8)
                            .padding(.horizontal)
                        
                        if viewModel.articles.isEmpty {
                            Text("No articles yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(viewModel.articles) { article in
                                NavigationLink(destination: ArticleDetailView(article: article)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let imageURL = article.imageURL {
                                            CachedAsyncImage(url: imageURL) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(height: 200)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            } placeholder: {
                                                Color.gray.opacity(0.2)
                                                    .frame(height: 200)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            if !article.tags.isEmpty {
                                                Text(article.tags.first!)
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                    .textCase(.uppercase)
                                            }
                                            
                                            Text(article.title)
                                                .font(.headline)
                                                .lineLimit(2)
                                            
                                            Text(article.excerpt)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(3)
                                            
                                            Text(article.publishedAt.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Author Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAuthor(slug: authorSlug)
        }
    }
}
