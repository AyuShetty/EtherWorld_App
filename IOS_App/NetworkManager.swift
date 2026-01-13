import Foundation

// MARK: - Network Manager for API calls

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.etherworld.co" // Replace with actual API URL
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case unauthorized
        case serverError(String)
    }
    
    // MARK: - Magic Link Authentication
    
    func sendMagicLink(email: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/auth/magic-link") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Failed to send magic link")
        }
        
        return true
    }
    
    func verifyMagicLink(token: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/verify-magic-link") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["token": token]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.unauthorized
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse
    }
    
    // MARK: - Token Management
    
    func refreshToken(_ token: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/refresh") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.unauthorized
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse
    }
    
    // MARK: - Session Management
    
    func getSessions(token: String) async throws -> [SessionData] {
        guard let url = URL(string: "\(baseURL)/auth/sessions") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Failed to fetch sessions")
        }
        
        let sessions = try JSONDecoder().decode([SessionData].self, from: data)
        return sessions
    }
    
    func revokeSession(sessionId: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/sessions/\(sessionId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Failed to revoke session")
        }
    }
    
    // MARK: - Newsletter Subscription
    
    func subscribeNewsletter(email: String) async throws {
        guard let url = URL(string: "\(baseURL)/newsletter/subscribe") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "tags": ["weekly"]]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NetworkError.serverError("Failed to subscribe")
        }
    }
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let token: String
    let user: UserData
    let expiresAt: Date?
}

struct UserData: Codable {
    let id: String
    let email: String
    let name: String?
    let authProvider: String
    let createdAt: Date?
}

struct SessionData: Codable {
    let id: String
    let deviceName: String
    let deviceType: String
    let lastActive: Date
    let location: String?
}
