import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let fullName: String
    let email: String
    let profileImageUrl: String?
    
    // Физические параметры
    let height: Int?
    let weight: Int?
    let age: Int?
    
    // Статистика
    let trainingDays: Int
    let totalWorkouts: Int
    let rank: String
    let level: Int
    
    // Дополнительные данные
    let joinDate: Date
    let isActive: Bool
}

// Пример данных пользователя для предварительного просмотра
extension User {
    static let example = User(
        id: "1",
        username: "boxer123",
        fullName: "Александр Иванов",
        email: "alex@example.com",
        profileImageUrl: nil,
        height: 180,
        weight: 75,
        age: 28,
        trainingDays: 15,
        totalWorkouts: 32,
        rank: "Новичок",
        level: 1,
        joinDate: Date(),
        isActive: true
    )
}
