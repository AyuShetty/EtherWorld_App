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
        // TEMP LOGIN (MVP): allow entry after email.
        // We intentionally avoid showing errors here.
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Small delay for UX parity with a real network call.
        try? await Task.sleep(nanoseconds: 250_000_000)

        let token = UUID().uuidString
        let user = User(
            id: UUID().uuidString,
            email: trimmed,
            name: extractName(from: trimmed),
            authProvider: .email
        )

        // Persist if possible; if not, still allow entry.
        _ = KeychainHelper.shared.save(token, forKey: tokenKey)
        saveUserData(user)
        isAuthenticated = true
        currentUser = user
    }
    
    func verifyMagicLinkToken(_ token: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await NetworkManager.shared.verifyMagicLink(token: token)
            
            let user = User(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name,
                authProvider: .email
            )
            
            if KeychainHelper.shared.save(response.token, forKey: tokenKey) {
                saveUserData(user)
                isAuthenticated = true
                currentUser = user
            } else {
                errorMessage = "Failed to save authentication token"
            }
        } catch {
            errorMessage = "Invalid or expired magic link"
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
