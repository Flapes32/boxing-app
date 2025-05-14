import Foundation

extension Exercise {
    // Примеры упражнений (используются в DataService и предпросмотре UI)
    static let examples: [Exercise] = [
        Exercise(
            id: UUID().uuidString,
            name: "Джеб",
            description: "Базовый прямой удар передней рукой",
            instructions: "Из боевой стойки выполните быстрый прямой удар передней рукой.",
            category: .technique,
            difficulty: .beginner,
            targetMuscles: [.arms, .shoulders],
            duration: nil,
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: nil,
            tips: ["Сохраняйте защиту второй рукой"],
            commonMistakes: ["Опускаете подбородок"],
            equipment: ["Боксерские перчатки"]
        ),
        Exercise(
            id: UUID().uuidString,
            name: "Скакалка",
            description: "Кардио упражнение для выносливости",
            instructions: "Прыгайте через скакалку в устойчивом темпе.",
            category: .cardio,
            difficulty: .beginner,
            targetMuscles: [.legs, .fullBody],
            duration: 300,
            repetitions: nil,
            sets: nil,
            restBetweenSets: nil,
            videoURL: nil,
            tips: ["Держите локти близко к корпусу"],
            commonMistakes: ["Слишком высокие прыжки"],
            equipment: ["Скакалка"]
        )
    ]
}
