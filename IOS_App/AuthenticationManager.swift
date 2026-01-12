import Foundation
import SwiftUI
import Combine
import AuthenticationServices

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    struct User: Codable {
        let id: String
        let email: String
        let name: String?
        let authProvider: AuthProvider
    }
    
    enum AuthProvider: String, Codable {
        case email
        case apple
        case google
    }
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let token = KeychainHelper.shared.get(forKey: tokenKey),
           !token.isEmpty {
            isAuthenticated = true
            loadUserData()
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func sendMagicLink(email: String) async {
        guard !email.isEmpty else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Simulate API call to send magic link
        // In production, replace with actual API endpoint
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s delay
        
        // For demo: automatically authenticate any email
        let token = UUID().uuidString
        let user = User(
            id: UUID().uuidString,
            email: email,
            name: extractName(from: email),
            authProvider: .email
        )
        
        if KeychainHelper.shared.save(token, forKey: tokenKey) {
            saveUserData(user)
            isAuthenticated = true
            currentUser = user
        } else {
            errorMessage = "Failed to save authentication token"
        }
    }
    
    func signInWithApple(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Failed to get Apple ID credentials"
            return
        }
        
        let userID = appleIDCredential.user
        let email = appleIDCredential.email ?? "\(userID)@privaterelay.appleid.com"
        let fullName = appleIDCredential.fullName
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let token = UUID().uuidString
        let user = User(
            id: userID,
            email: email,
            name: name.isEmpty ? nil : name,
            authProvider: .apple
        )
        
        if KeychainHelper.shared.save(token, forKey: tokenKey) {
            saveUserData(user)
            isAuthenticated = true
            currentUser = user
        } else {
            errorMessage = "Failed to save authentication token"
        }
    }
    
    func signInWithGoogle() async {
        // Google Sign-In requires Firebase SDK or Google Sign-In SDK
        // This is a placeholder for future implementation
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        errorMessage = "Google Sign-In requires additional setup. Please use email or Apple sign-in for now."
    }
    
    func logout() {
        _ = KeychainHelper.shared.delete(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        isAuthenticated = false
        currentUser = nil
    }
    
    private func loadUserData() {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
    }
    
    private func saveUserData(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: userKey)
        currentUser = user
    }
    
    private func extractName(from email: String) -> String? {
        let name = email.components(separatedBy: "@").first?
            .replacingOccurrences(of: ".", with: " ")
            .capitalized
        return name
    }
}
