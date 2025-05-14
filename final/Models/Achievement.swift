import Foundation
import SwiftUI

// Модель достижения пользователя
struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let progress: Int
    let total: Int
    let iconName: String
    
    // Вычисляемое свойство для процента выполнения
    var progressPercentage: Double {
        return Double(progress) / Double(total)
    }
    
    // Вычисляемое свойство для определения, завершено ли достижение
    var isCompleted: Bool {
        return progress >= total
    }
    
    // Вычисляемое свойство для цвета достижения
    var color: Color {
        if isCompleted {
            return .green
        } else if progressPercentage > 0.5 {
            return .yellow
        } else {
            return .blue
        }
    }
}

// Примеры достижений для предварительного просмотра
extension Achievement {
    static let examples = [
        Achievement(id: "1", title: "Первые шаги", description: "Выполните 5 тренировок", progress: 5, total: 5, iconName: "figure.walk"),
        Achievement(id: "2", title: "Мастер комбо", description: "Выполните 10 комбинаций", progress: 7, total: 10, iconName: "bolt.fill"),
        Achievement(id: "3", title: "Железный кулак", description: "Выполните 100 ударов за тренировку", progress: 85, total: 100, iconName: "hand.raised.fill")
    ]
}
