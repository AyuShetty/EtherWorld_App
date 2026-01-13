//
//  IOS_AppApp.swift
//  IOS_App
//
//  Created by Ayush Shetty on 05/01/26.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct IOS_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var authManager = AuthenticationManager()
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue
    @AppStorage("darkModeEnabled") private var legacyDarkModeEnabled: Bool = false

    private var resolvedTheme: AppTheme {
        AppTheme(rawValue: appThemeRaw) ?? AppTheme.fromUserDefaults()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // One-time migration:
        // - If a user previously had only the legacy `darkModeEnabled` setting, preserve it.
        // - If neither exists (fresh install), default to system.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "appTheme") == nil {
            if defaults.object(forKey: "darkModeEnabled") != nil {
                appThemeRaw = (legacyDarkModeEnabled ? AppTheme.dark : AppTheme.light).rawValue
            } else {
                appThemeRaw = AppTheme.system.rawValue
            }
        }

        // Register background refresh task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundRefreshManager.taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            BackgroundRefreshManager.handle(task: refreshTask)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    AdaptiveContentView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .preferredColorScheme(resolvedTheme.preferredColorScheme)
            .onChange(of: appThemeRaw) { _, newValue in
                // Keep legacy key consistent for any existing code paths.
                let resolved = AppTheme(rawValue: newValue) ?? .system
                legacyDarkModeEnabled = (resolved == .dark)
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Schedule next refresh when app becomes active
                BackgroundRefreshManager.scheduleNextRefresh(hoursFromNow: 6)
                AnalyticsManager.shared.log(.appOpen)
            }
        }
        .backgroundTask(.appRefresh(BackgroundRefreshManager.taskIdentifier)) {
            await BackgroundRefreshManager.performRefresh()
        }
    }
}
