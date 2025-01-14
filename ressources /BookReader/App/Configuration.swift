import Foundation

enum Configuration {
    enum API {
        static let baseURL = "https://bookreaderserver.onrender.com/api"
        
        enum Endpoints {
            static let login = "/auth/login"
            static let register = "/auth/register"
            static let resetPassword = "/auth/reset-password"
        }
        
        enum Headers {
            static let contentType = "Content-Type"
            static let authorization = "Authorization"
            static let applicationJSON = "application/json"
            static let bearer = "Bearer"
        }
    }
    
    enum UserDefaults {
        static let authToken = "authToken"
    }
} 