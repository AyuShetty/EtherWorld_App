import Foundation
import BackgroundTasks

enum BackgroundRefreshManager {
    static let taskIdentifier = "co.etherworld.refresh"

    static func scheduleNextRefresh(hoursFromNow hours: Double = 6) {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: hours * 3600)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background refresh: \(error)")
        }
    }

    static func handle(task: BGAppRefreshTask) {
        scheduleNextRefresh(hoursFromNow: 6)
        task.expirationHandler = {
            // Cancel work if needed
        }
        Task {
            let success = await performRefresh()
            task.setTaskCompleted(success: success)
        }
    }

    @discardableResult
    static func performRefresh() async -> Bool {
        do {
            // Fetch the latest article only to minimize work
            let service = GhostArticleService()
            let articles = try await service.fetchArticles(page: 1, limit: 1)
            await MainActor.run {
                NotificationManager.shared.checkForNewArticles(articles: articles)
            }
            return true
        } catch {
            print("Background refresh failed: \(error)")
            return false
        }
    }
}
