import Foundation

// Общая модель данных для обмена между iPhone и Apple Watch
struct WatchWorkoutData: Codable {
    let timestamp: TimeInterval
    let heartRate: Double
    let activeEnergy: Double
    let workoutDuration: Double
    let steps: Int
    let distance: Double // в метрах
    let rounds: Int
    let isInProgress: Bool
    
    // Дополнительные данные о тренировке
    let avgHeartRate: Double
    let maxHeartRate: Double
    let restingHeartRate: Double?
    
    // Идентификатор тренировки для синхронизации
    let workoutId: String
    
    static let sample = WatchWorkoutData(
        timestamp: Date().timeIntervalSince1970,
        heartRate: 130,
        activeEnergy: 350,
        workoutDuration: 900,
        steps: 2000,
        distance: 2400,
        rounds: 3,
        isInProgress: true,
        avgHeartRate: 125,
        maxHeartRate: 165,
        restingHeartRate: 65,
        workoutId: UUID().uuidString
    )
}

// Модель для передачи настроек таймера с iPhone на Apple Watch
struct TimerSettings: Codable, Equatable {
    let workDuration: Int // в секундах
    let restDuration: Int // в секундах
    let rounds: Int
    let exercises: [ExerciseData]
    
    static let `default` = TimerSettings(
        workDuration: 180,
        restDuration: 60,
        rounds: 3,
        exercises: []
    )
}

// Упрощенная модель упражнения для передачи на Apple Watch
struct ExerciseData: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let rounds: Int
    
    init(id: String = UUID().uuidString, name: String, rounds: Int) {
        self.id = id
        self.name = name
        self.rounds = rounds
    }
}

// Команды для обмена между устройствами
enum WatchCommand: String, Codable {
    case startWorkout
    case pauseWorkout
    case resumeWorkout
    case stopWorkout
    case updateSettings
    case requestData
    case syncExercises
}

// Структура для отправки команд
struct WatchMessage: Codable {
    let command: WatchCommand
    let data: Data?
    
    init(command: WatchCommand, data: Data? = nil) {
        self.command = command
        self.data = data
    }
}
