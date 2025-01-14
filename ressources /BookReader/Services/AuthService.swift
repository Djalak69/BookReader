import Foundation

enum AuthError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case invalidCredentials
    case serverError(String)
}

class AuthService {
    static let shared = AuthService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func login(email: String, password: String) async throws -> String {
        guard let url = URL(string: Configuration.API.baseURL + Configuration.API.Endpoints.login) else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Configuration.API.Headers.applicationJSON, forHTTPHeaderField: Configuration.API.Headers.contentType)
        
        let credentials = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw AuthError.invalidCredentials
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                throw AuthError.serverError(errorMessage)
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            UserDefaults.standard.set(loginResponse.token, forKey: Configuration.UserDefaults.authToken)
            return loginResponse.token
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> String {
        do {
            let (user, _) = try await apiService.register(email: email, username: username, password: password)
            // Après l'inscription réussie, connectez automatiquement l'utilisateur
            return try await login(email: email, password: password)
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            _ = try await apiService.resetPassword(email: email)
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func logout() {
        apiService.logout()
    }
    
    func checkAndRestoreToken() -> Bool {
        return UserDefaults.standard.string(forKey: Configuration.UserDefaults.authToken) != nil
    }
}

// MARK: - Response Models
private struct LoginResponse: Codable {
    let token: String
    let user: User
}

private struct RegisterResponse: Codable {
    let token: String
    let user: User
} 