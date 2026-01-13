import Foundation
import UserNotifications
import SwiftUI
import Combine

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var selectedArticleId: String?
    private var lastArticleId: String {
        get { UserDefaults.standard.string(forKey: "lastArticleId") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "lastArticleId") }
    }
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }

    // Preferences
    private var selectedTags: [String] {
        get { UserDefaults.standard.stringArray(forKey: "notificationTags") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "notificationTags") }
    }
    private var quietStartHour: Int { UserDefaults.standard.integer(forKey: "quietStartHour") }
    private var quietEndHour: Int { UserDefaults.standard.integer(forKey: "quietEndHour") }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    UNUserNotificationCenter.current().delegate = self
                }
                completion(granted)
            }
        }
    }
    
    func checkForNewArticles(articles: [Article]) {
        guard isAuthorized else { return }
        guard let latestArticle = articles.first else { return }

        // Respect quiet hours
        if isWithinQuietHours(Date()) { return }
        
        // If this is first run, just store the ID
        if lastArticleId.isEmpty {
            lastArticleId = latestArticle.id
            return
        }
        
        // Check if there's a new article
        if latestArticle.id != lastArticleId {
            if articleMatchesPreferences(latestArticle) {
                sendNewArticleNotification(article: latestArticle)
                lastArticleId = latestArticle.id
            } else {
                // Even if topic filtered out, advance last seen to avoid repeat
                lastArticleId = latestArticle.id
            }
        }
    }

    private func isWithinQuietHours(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        if quietStartHour == quietEndHour { return false }
        if quietStartHour < quietEndHour {
            // e.g., 22 -> 7 is invalid in this branch
            return hour >= quietStartHour && hour < quietEndHour
        } else {
            // Wrap around midnight, e.g., 23 -> 7
            return hour >= quietStartHour || hour < quietEndHour
        }
    }

    private func articleMatchesPreferences(_ article: Article) -> Bool {
        let prefs = Set(selectedTags)
        if prefs.isEmpty { return true }
        let normalized = article.tags.map { t -> String in
            let n = t.lowercased().trimmingCharacters(in: .whitespaces)
            return n.hasPrefix("#") ? String(n.dropFirst()) : n
        }
        return normalized.contains(where: { prefs.contains($0) })
    }
    
    func sendNewArticleNotification(article: Article) {
        let content = UNMutableNotificationContent()
        content.title = "New Article on EtherWorld"
        content.body = article.title
        content.sound = .default
        content.userInfo = ["articleId": article.id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: article.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
    
    func scheduleBackgroundCheck() {
        // Schedule a local notification reminder to check for articles
        // In a production app, you'd use push notifications from a server
        let content = UNMutableNotificationContent()
        content.title = "Check for new articles"
        content.body = "Open the app to see the latest from EtherWorld"
        content.sound = .default
        
        // Schedule for every 6 hours
        var dateComponents = DateComponents()
        dateComponents.hour = 6
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6 * 60 * 60, repeats: true)
        
        let request = UNNotificationRequest(identifier: "backgroundCheck", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let articleId = response.notification.request.content.userInfo["articleId"] as? String {
            selectedArticleId = articleId
        }
        completionHandler()
    }
}
