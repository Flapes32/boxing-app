import Foundation
import RealmSwift

// Сервис для работы с сессиями тренировок
class WorkoutSessionService {
    static let shared = WorkoutSessionService()
    
    private let database = Database<WorkoutSession>()
    
    // Сохранение новой сессии тренировки
    func saveWorkoutSession(exercises: [WorkoutExercise], totalDuration: Int) -> WorkoutSession {
        let session = WorkoutSession(date: Date(), totalDuration: totalDuration)
        
        // Добавляем результаты для каждого упражнения
        for exercise in exercises {
            let result = ExerciseResult(
                exerciseId: exercise.exercise.id,
                exerciseName: exercise.exercise.name,
                completedRounds: exercise.completedRounds,
                totalRounds: exercise.rounds,
                duration: exercise.rounds * (totalDuration / exercises.count) // примерное время на упражнение
            )
            
            session.exerciseResults.append(result)
        }
        
        // Сохраняем сессию в базу данных
        database.save(session)
        
        return session
    }
    
    // Получение всех сессий тренировок
    func getAllSessions() -> Results<WorkoutSession> {
        return database.getAllEntities().sorted(byKeyPath: "date", ascending: false)
    }
    
    // Получение сессий за определенный период
    func getSessionsForPeriod(startDate: Date, endDate: Date) -> Results<WorkoutSession> {
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        return database.getEntities(filter: predicate).sorted(byKeyPath: "date", ascending: false)
    }
    
    // Получение статистики по упражнениям
    func getExerciseStatistics(exerciseId: String) -> [ExerciseResult] {
        let sessions = database.getAllEntities()
        var results: [ExerciseResult] = []
        
        for session in sessions {
            for result in session.exerciseResults where result.exerciseId == exerciseId {
                results.append(result)
            }
        }
        
        return results
    }
    
    // Удаление сессии
    func deleteSession(session: WorkoutSession) {
        database.delete(session)
    }
}
