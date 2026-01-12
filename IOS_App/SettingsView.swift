import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("analyticsEnabled") private var analyticsEnabled = false
    @AppStorage("newsletterOptIn") private var newsletterOptIn = false
    @State private var showingPrivacyPolicy = false
    @State private var showingLogoutConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Article Notifications")
                                    .fontWeight(.medium)
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
                            HapticFeedback.light()
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                // Appearance Section
                Section {
                    Toggle(isOn: $darkModeEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            Text("Dark Mode")
                                .fontWeight(.medium)
                        }
                    }
                    .onChange(of: darkModeEnabled) { _, _ in
                        HapticFeedback.light()
                    }
                } header: {
                    Text("Appearance")
                }
                
                // Privacy & Data Section
                Section {
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.green)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            Text("Privacy Policy")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Toggle(isOn: $analyticsEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analytics & Diagnostics")
                                    .fontWeight(.medium)
                                Text("Help improve the app")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: analyticsEnabled) { _, _ in
                        HapticFeedback.light()
                    }
                } header: {
                    Text("Privacy")
                }

                // Newsletter Section
                Section {
                    Toggle(isOn: $newsletterOptIn) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.orange)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weekly Newsletter")
                                    .fontWeight(.medium)
                                Text("Get a concise recap of the week via email")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: newsletterOptIn) { _, _ in
                        HapticFeedback.light()
                    }
                } header: {
                    Text("Newsletter")
                }
                
                // About Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                            .frame(width: 28)
                            .font(.system(size: 16))
                        Text("Version")
                            .fontWeight(.medium)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://etherworld.co")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            Text("Visit EtherWorld")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Link(destination: URL(string: "https://twitter.com/AayushS20298601")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "at")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            Text("Follow on Twitter")
                                .fontWeight(.medium)
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
                
                // Account Section
                Section {
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Signed in as")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(user.email)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(role: .destructive) {
                        showingLogoutConfirmation = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.red)
                                .frame(width: 28)
                                .font(.system(size: 16))
                            Text("Sign Out")
                                .fontWeight(.medium)
                        }
                    }
                } header: {
                    Text("Account")
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
                    .accessibilityLabel("Trigger background refresh")
                    .accessibilityHint("Manually triggers the background refresh to check for new articles and send a test notification")
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
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to sign out? Your saved articles and preferences will be preserved.")
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
