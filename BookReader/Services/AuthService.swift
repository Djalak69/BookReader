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
    private let baseURL = "https://bookreaderserver.onrender.com/api"
    
    private init() {}
    
    func login(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
            
            struct LoginResponse: Codable {
                let token: String
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Mettre à jour le token dans BookService
            BookService.shared.setAuthToken(loginResponse.token)
            
            // Sauvegarder le token pour une utilisation ultérieure
            UserDefaults.standard.set(loginResponse.token, forKey: "authToken")
            
            return loginResponse.token
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func register(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                throw AuthError.serverError(errorMessage)
            }
            
            struct RegisterResponse: Codable {
                let token: String
            }
            
            let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
            
            // Mettre à jour le token dans BookService
            BookService.shared.setAuthToken(registerResponse.token)
            
            // Sauvegarder le token pour une utilisation ultérieure
            UserDefaults.standard.set(registerResponse.token, forKey: "authToken")
            
            return registerResponse.token
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func logout() {
        // Supprimer le token
        UserDefaults.standard.removeObject(forKey: "authToken")
        BookService.shared.setAuthToken("")
    }
    
    func checkAndRestoreToken() {
        if let savedToken = UserDefaults.standard.string(forKey: "authToken") {
            BookService.shared.setAuthToken(savedToken)
        }
    }
} 