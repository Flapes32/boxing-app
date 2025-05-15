//
//  WorkoutRecord.swift
//  final
//
//  Created on 15.05.25.
//

import Foundation
import RealmSwift

// Модель для хранения записей о выполненных упражнениях
class WorkoutRecord: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var exerciseId: String = ""
    @Persisted var exerciseName: String = ""
    @Persisted var repetitions: Int = 0
    @Persisted var date: Date = Date()
    
    convenience init(exerciseId: String, exerciseName: String, repetitions: Int) {
        self.init()
        self.id = UUID().uuidString
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.repetitions = repetitions
        self.date = Date()
    }
}

// Сервис для работы с записями тренировок
class WorkoutRecordService {
    static let shared = WorkoutRecordService()
    private let database = Database<WorkoutRecord>()
    
    // Сохранить запись о выполненном упражнении
    func saveWorkoutRecord(exerciseId: String, exerciseName: String, repetitions: Int) {
        let record = WorkoutRecord(exerciseId: exerciseId, exerciseName: exerciseName, repetitions: repetitions)
        database.save(record)
    }
    
    // Получить все записи о тренировках
    func getAllWorkoutRecords() -> Results<WorkoutRecord> {
        return database.getAllEntities()
    }
    
    // Получить записи для конкретного упражнения
    func getWorkoutRecords(forExerciseId exerciseId: String) -> Results<WorkoutRecord> {
        let predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        return database.getEntities(filter: predicate)
    }
    
    // Удалить запись
    func deleteWorkoutRecord(_ record: WorkoutRecord) {
        database.delete(record)
    }
}
