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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Schedule next refresh when app becomes active
                BackgroundRefreshManager.scheduleNextRefresh(hoursFromNow: 6)
            }
        }
        .backgroundTask(.appRefresh(BackgroundRefreshManager.taskIdentifier)) {
            await BackgroundRefreshManager.performRefresh()
        }
    }
}
