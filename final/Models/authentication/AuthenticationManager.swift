import Foundation
import FirebaseAuth

// Модель данных пользователя для аутентификации
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

// Ошибки аутентификации
enum AuthenticationError: Error {
    case invalidEmail
    case invalidPassword
    case userNotFound
    case weakPassword
    case emailAlreadyInUse
    case networkError
    case unknown(Error)
    
    var message: String {
        switch self {
        case .invalidEmail:
            return "Неверный формат email"
        case .invalidPassword:
            return "Неверный пароль"
        case .userNotFound:
            return "Пользователь не найден"
        case .weakPassword:
            return "Слишком простой пароль. Минимум 6 символов"
        case .emailAlreadyInUse:
            return "Email уже используется"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .unknown(let error):
            return "Ошибка: \(error.localizedDescription)"
        }
    }
}

// Менеджер аутентификации
@MainActor
final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    // Текущий пользователь
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        return AuthDataResultModel(user: user)
    }
    
    // Создание нового пользователя
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch {
            throw handleAuthError(error)
        }
    }
    
    // Вход по email/password
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch {
            throw handleAuthError(error)
        }
    }
    
    // Выход из аккаунта
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Сброс пароля
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw handleAuthError(error)
        }
    }
    
    // Обработка ошибок Firebase
    private func handleAuthError(_ error: Error) -> AuthenticationError {
        let authError = error as NSError
        let errorCode = AuthErrorCode(_bridgedNSError: authError)
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .invalidPassword
        case .userNotFound:
            return .userNotFound
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .networkError:
            return .networkError
        default:
            return .unknown(error)
        }
    }
}
