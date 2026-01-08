import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            VStack(alignment: .leading) {
                                Text("New Article Notifications")
                                Text("Get notified when new articles are published")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            notificationManager.requestPermission { granted in
                                if !granted {
                                    notificationsEnabled = false
                                }
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                // Appearance Section
                Section {
                    Toggle(isOn: $darkModeEnabled) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                                .frame(width: 28)
                            Text("Dark Mode")
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                            .frame(width: 28)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://etherworld.co")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            Text("Visit EtherWorld")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Link(destination: URL(string: "https://twitter.com/AayushS20298601")!) {
                        HStack {
                            Image(systemName: "at")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            Text("Follow on Twitter")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("About")
                }
                
                // Cache Section
                Section {
                    Button {
                        clearCache()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                                .frame(width: 28)
                            Text("Clear Cache")
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Text("Storage")
                }

                // Developer Section (Debug Tools)
                Section {
                    Button {
                        Task { await BackgroundRefreshManager.performRefresh() }
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(.orange)
                                .frame(width: 28)
                            Text("Trigger Background Refresh Now")
                        }
                    }
                    .disabled(!notificationManager.isAuthorized)
                } header: {
                    Text("Developer")
                } footer: {
                    Text("Grant notification permission first to see a test alert when a new article is detected.")
                }
            }
            .navigationTitle("Settings")
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
        }
    }
    
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        // Clear JSON article cache
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("articles-cache.json")
        try? FileManager.default.removeItem(at: cacheURL)
        // Clear image cache
        ImageCache.shared.clear()
        let imagesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("images")
        try? FileManager.default.removeItem(at: imagesDir)
    }
}

#Preview {
    SettingsView()
}
