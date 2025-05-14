import Foundation

enum WorkoutDifficulty: String, Codable, CaseIterable {
    case beginner = "Начинающий"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
    case professional = "Профессионал"
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case warmup = "Разминка"
    case technique = "Техника"
    case strength = "Силовые"
    case cardio = "Кардио"
    case cooldown = "Заминка"
    case stretching = "Растяжка"
    case combinations = "Комбинации"
    
    var icon: String {
        switch self {
        case .warmup: return "flame.fill"
        case .technique: return "figure.boxing"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .cooldown: return "wind"
        case .stretching: return "figure.flexibility"
        case .combinations: return "figure.boxing.motion"
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case arms = "Руки"
    case shoulders = "Плечи"
    case chest = "Грудь"
    case back = "Спина"
    case core = "Кор"
    case legs = "Ноги"
    case fullBody = "Все тело"
}

struct Exercise: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let instructions: String
    let category: ExerciseCategory
    let difficulty: WorkoutDifficulty
    let targetMuscles: [MuscleGroup]
    let duration: Int? // в секундах
    let repetitions: Int?
    let sets: Int?
    let restBetweenSets: Int? // в секундах
    let videoURL: String?
    let tips: [String]
    let commonMistakes: [String]
    let equipment: [String]
    
    // Вычисляемое свойство для отображения формата упражнения
    var format: String {
        if let repetitions = repetitions, let sets = sets {
            return "\(sets) × \(repetitions)"
        } else if let duration = duration {
            let minutes = duration / 60
            let seconds = duration % 60
            if minutes > 0 {
                return "\(minutes) мин \(seconds) сек"
            } else {
                return "\(seconds) сек"
            }
        } else {
            return "Произвольно"
        }
    }
}

// База данных упражнений
struct ExerciseDatabase {
    static let exercises: [Exercise] = [
        // Разминка
        Exercise(
            id: "warmup-1",
            name: "Техника",
            description: "Основные техники бокса",
            instructions: "Примите боевую стойку",
            category: .warmup,
            difficulty: .beginner,
            targetMuscles: [.legs, .core],
            duration: 10,
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=FJmRQ5iTXKE",
            tips: ["Начните с базовых прыжков"],
            commonMistakes: ["Слишком высокие прыжки"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // Техника
        Exercise(
            id: "technique-1",
            name: "Техника",
            description: "Основные техники бокса",
            instructions: "Примите боевую стойку",
            category: .technique,
            difficulty: .beginner,
            targetMuscles: [.arms, .shoulders],
            duration: 10,
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=1D9v6KtBQrk",
            tips: ["Держите вторую руку у подбородка", "Разворачивайте кулак в конце удара"],
            commonMistakes: ["Опущенная вторая рука"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        Exercise(
            id: "technique-2",
            name: "Кросс",
            description: "Боксерская техника кросса",
            instructions: "Из боевой стойки",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders],
            duration: 15,
            repetitions: 8,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=2Xo3NJ7LCCw",
            tips: ["Используйте вращение бедер", "Держите защиту"],
            commonMistakes: ["Нет вращения корпуса"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // Комбинации
        Exercise(
            id: "combinations-1",
            name: "Джеб",
            description: "Боксерская техника джеба",
            instructions: "Джеб передней рукой",
            category: .combinations,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders],
            duration: 20,
            repetitions: 5,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=7v0_uipNGao",
            tips: ["Начинайте медленно", "Следите за точностью"],
            commonMistakes: ["Остановка между ударами"],
            equipment: ["Боксерские перчатки", "Бинты", "Груша"]
        ),
        Exercise(
            id: "technique-3",
            name: "Бой с тенью",
            description: "Постоянное движение",
            instructions: "Постоянное движение",
            category: .technique,
            difficulty: .advanced,
            targetMuscles: [.fullBody],
            duration: 45,
            repetitions: 2,
            sets: 2,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=kqB19LuJ5jE",
            tips: ["Представляйте реального противника", "Работайте в разных темпах"],
            commonMistakes: ["Отсутствие защитных действий"],
            equipment: ["Боксерские перчатки (опционально)"]
        )
    ]
}
