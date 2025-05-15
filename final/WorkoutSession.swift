import Foundation
import RealmSwift

// Модель для хранения результатов сессии тренировки
class WorkoutSession: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var date: Date = Date()
    @Persisted var exerciseResults = List<ExerciseResult>()
    @Persisted var totalDuration: Int = 0 // в секундах
    
    convenience init(date: Date, totalDuration: Int) {
        self.init()
        self.date = date
        self.totalDuration = totalDuration
    }
}

// Модель для хранения результатов упражнения в сессии
class ExerciseResult: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var exerciseId: String = ""
    @Persisted var exerciseName: String = ""
    @Persisted var completedRounds: Int = 0
    @Persisted var totalRounds: Int = 0
    @Persisted var duration: Int = 0 // в секундах
    
    convenience init(exerciseId: String, exerciseName: String, completedRounds: Int, totalRounds: Int, duration: Int) {
        self.init()
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.completedRounds = completedRounds
        self.totalRounds = totalRounds
        self.duration = duration
    }
}
