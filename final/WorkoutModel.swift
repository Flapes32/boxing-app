import Foundation

// Категории тренировок
enum WorkoutCategory: String, Codable, CaseIterable {
    case technique = "Техника"
    case cardio = "Кардио"
    case strength = "Силовые"
    case flexibility = "Гибкость"
    case functional = "Функциональные"
    case warmup = "Разминка"
    case stretching = "Растяжка"
    
    var icon: String {
        switch self {
        case .technique: return "figure.boxing"
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .flexibility, .stretching: return "figure.flexibility"
        case .functional: return "flame"
        case .warmup: return "flame.fill"
        }
    }
}

// Модель тренировки, используемая в сервисах и UI
struct WorkoutModel: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let difficulty: String          // rawValue из WorkoutDifficulty
    let category: String            // rawValue из WorkoutCategory
    let duration: Int               // в минутах
    let caloriesBurn: Int           // kcal
    let exercises: [Exercise]
    let imageUrl: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         difficulty: String,
         category: String,
         duration: Int,
         caloriesBurn: Int,
         exercises: [Exercise] = [],
         imageUrl: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.category = category
        self.duration = duration
        self.caloriesBurn = caloriesBurn
        self.exercises = exercises
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }
}

