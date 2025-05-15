import Foundation

// Структура для хранения упражнения с количеством раундов
struct WorkoutExercise: Identifiable {
    let id: UUID = UUID()
    let exercise: Exercise
    var rounds: Int
    var completedRounds: Int = 0
    
    var isCompleted: Bool {
        completedRounds >= rounds
    }
    
    var remainingRounds: Int {
        max(0, rounds - completedRounds)
    }
}
