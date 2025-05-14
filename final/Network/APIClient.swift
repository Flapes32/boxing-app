import Foundation

// Класс для работы с API боксерского приложения
class APIClient {
    // Синглтон для доступа к API-клиенту
    static let shared = APIClient()
    
    // Сетевой менеджер для выполнения запросов
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Аутентификация
    
    // Структура для запроса авторизации
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }
    
    // Структура для ответа авторизации
    struct AuthResponse: Codable {
        let token: String
        let user: User
        
        enum CodingKeys: String, CodingKey {
            case token
            case user
        }
    }
    
    // Метод для авторизации пользователя
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        return try await networkManager.post(endpoint: "/auth/login", body: request)
    }
    
    // Метод для выхода из системы
    func logout() {
        networkManager.clearAuthToken()
    }
    
    // MARK: - Пользователи
    
    // Метод для получения данных текущего пользователя
    func getCurrentUser() async throws -> User {
        return try await networkManager.get(endpoint: "/users/me")
    }
    
    // Метод для обновления данных пользователя
    func updateUser(userId: String, userData: UpdateUserRequest) async throws -> User {
        return try await networkManager.put(endpoint: "/users/\(userId)", body: userData)
    }
    
    // Структура для запроса обновления пользователя
    struct UpdateUserRequest: Codable {
        let fullName: String?
        let height: Int?
        let weight: Int?
        let age: Int?
    }
    
    // MARK: - Тренировки
    
    // Метод для получения списка тренировок
    func getWorkouts(page: Int = 1, limit: Int = 20, category: WorkoutCategory? = nil, difficulty: WorkoutDifficulty? = nil) async throws -> [WorkoutModel] {
        var queryParams: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        if let category = category {
            queryParams["category"] = category.rawValue
        }
        
        if let difficulty = difficulty {
            queryParams["difficulty"] = difficulty.rawValue
        }
        
        return try await networkManager.get(endpoint: "/workouts", queryParams: queryParams)
    }
    
    // Метод для получения конкретной тренировки
    func getWorkout(id: String) async throws -> WorkoutModel {
        return try await networkManager.get(endpoint: "/workouts/\(id)")
    }
    
    // MARK: - Упражнения
    
    // Метод для получения списка упражнений
    func getExercises(page: Int = 1, limit: Int = 20, category: ExerciseCategory? = nil, difficulty: WorkoutDifficulty? = nil) async throws -> [Exercise] {
        var queryParams: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        if let category = category {
            queryParams["category"] = category.rawValue
        }
        
        if let difficulty = difficulty {
            queryParams["difficulty"] = difficulty.rawValue
        }
        
        return try await networkManager.get(endpoint: "/exercises", queryParams: queryParams)
    }
    
    // Метод для получения конкретного упражнения
    func getExercise(id: String) async throws -> Exercise {
        return try await networkManager.get(endpoint: "/exercises/\(id)")
    }
    
    // MARK: - Статистика
    
    // Структура для статистики пользователя
    struct UserStats: Codable {
        let totalWorkouts: Int
        let totalTime: Int
        let totalCalories: Int
        let weeklyActivity: [DailyActivity]
        let achievements: [Achievement]

        enum CodingKeys: String, CodingKey {
            case totalWorkouts
            case totalTime
            case totalCalories
            case weeklyActivity
            case achievements
        }
    }
    
    // Структура для ежедневной активности
    struct DailyActivity: Codable, Identifiable {
        let id = UUID()
        let day: String
        let value: Double
        
        enum CodingKeys: String, CodingKey {
            case day, value
        }
    }
    
    // Метод для получения статистики пользователя
    func getUserStats(userId: String) async throws -> UserStats {
        return try await networkManager.get(endpoint: "/users/\(userId)/stats")
    }
    
    // MARK: - Достижения
    
    // Метод для получения достижений пользователя
    func getUserAchievements(userId: String) async throws -> [Achievement] {
        return try await networkManager.get(endpoint: "/users/\(userId)/achievements")
    }
    
    // MARK: - Социальные функции
    
    // Структура для сообщения в чате
    struct ChatMessage: Codable, Identifiable {
        let id: String
        let senderId: String
        let senderName: String
        let text: String
        let timestamp: Date
        let attachmentType: String?
        let attachmentId: String?
    }
    
    // Метод для получения сообщений группы
    func getGroupMessages(groupId: String, page: Int = 1, limit: Int = 50) async throws -> [ChatMessage] {
        let queryParams = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        return try await networkManager.get(endpoint: "/groups/\(groupId)/messages", queryParams: queryParams)
    }
    
    // Структура для запроса отправки сообщения
    struct SendMessageRequest: Codable {
        let text: String
        let attachmentType: String?
        let attachmentId: String?
    }
    
    // Метод для отправки сообщения в группу
    func sendGroupMessage(groupId: String, message: SendMessageRequest) async throws -> ChatMessage {
        return try await networkManager.post(endpoint: "/groups/\(groupId)/messages", body: message)
    }
}
