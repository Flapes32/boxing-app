import Foundation

// MARK: - Stubbed RealmService
// В проекте пока нет реальной интеграции с Realm. Для компиляции
// и предварительного просмотра создаём заглушку, реализующую
// минимальный набор методов, используемых в DataService.
// Позже её можно заменить на полноценную реализацию.

enum RealmError: Error {
    case generic
}

@MainActor
final class RealmService {
    static let shared = RealmService()
    private init() {}
    
    // MARK: - CRUD
    func getUser(id: String) -> User? {
        nil // Пока нет сохранённых данных
    }
    
    func saveUser(_ user: User) throws {
        // В заглушке просто ничего не делаем
    }
    
    func getUserWorkouts(userId: String) -> [WorkoutModel] {
        []
    }
    
    func getUserAchievements(userId: String) -> [Achievement] {
        []
    }
    
    // MARK: - Observers
    func observeUser(id: String, _ handler: @escaping (User?) -> Void) {
        // Вызываем обработчик один раз с текущими (отсутствующими) данными
        handler(nil)
    }
    
    func observeUserWorkouts(userId: String, _ handler: @escaping ([WorkoutModel]) -> Void) {
        handler([])
    }
}
