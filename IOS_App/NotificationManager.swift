import Foundation
import UserNotifications
import SwiftUI
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    private var lastArticleId: String {
        get { UserDefaults.standard.string(forKey: "lastArticleId") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "lastArticleId") }
    }
    
    private init() {
        checkAuthorizationStatus()
    }
    
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
                completion(granted)
            }
        }
    }
    
    func checkForNewArticles(articles: [Article]) {
        guard isAuthorized else { return }
        guard let latestArticle = articles.first else { return }
        
        // If this is first run, just store the ID
        if lastArticleId.isEmpty {
            lastArticleId = latestArticle.id
            return
        }
        
        // Check if there's a new article
        if latestArticle.id != lastArticleId {
            sendNewArticleNotification(article: latestArticle)
            lastArticleId = latestArticle.id
        }
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
