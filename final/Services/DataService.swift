import Foundation
import Combine

// Убедитесь, что все свойства и методы определены
@MainActor
class DataService: ObservableObject, @unchecked Sendable {
    // Класс для работы с данными приложения
    static let shared = DataService()
    
    // API-клиент для сетевых запросов
    private let apiClient = APIClient.shared
    
    // Опубликованные свойства для обновления UI
    @Published var currentUser: User?
    @Published var workouts: [WorkoutModel] = []
    @Published var exercises: [Exercise] = []
    @Published var userStats: APIClient.UserStats?
    @Published var achievements: [Achievement] = []
    
    // Состояние загрузки и ошибки
    @Published var isLoading = false
    @Published var error: NetworkError?
    
    // Флаг авторизации - всегда true для упрощения без аутентификации
    @Published var isAuthenticated = true
    
    private init() {
        // Создаем тестового пользователя
        createTestUser()
        
        // Загрузка тестовых данных
        Task {
            await loadMockData()
        }
    }
    
    // Создание тестового пользователя
    private func createTestUser() {
        let testUser = User(
            id: "test-user-id",
            username: "testuser",
            fullName: "Тестовый Пользователь",
            email: "test@example.com",
            profileImageUrl: nil,
            height: 180,
            weight: 75,
            age: 30,
            trainingDays: 15,
            totalWorkouts: 25,
            rank: "Любитель",
            level: 3,
            joinDate: Date(),
            isActive: true
        )
        
        self.currentUser = testUser
        
        do {
            try RealmService.shared.saveUser(testUser)
            setupObservers(userId: testUser.id)
        } catch {
            print("Ошибка при создании тестового пользователя: \(error)")
        }
    }
    
    // Настройка наблюдателей Realm
    private func setupObservers(userId: String) {
        // Наблюдение за пользователем
        RealmService.shared.observeUser(id: userId) { [weak self] user in
            self?.currentUser = user
        }
        
        // Наблюдение за тренировками
        RealmService.shared.observeUserWorkouts(userId: userId) { [weak self] workouts in
            self?.workouts = workouts
        }
    }
    
    // MARK: - Загрузка данных
    
    // Загрузка начальных данных после авторизации
    func loadInitialData() async {
        await loadCurrentUser()
        await loadWorkouts()
        await loadUserStats()
        await loadAchievements()
    }
    
    // Загрузка данных текущего пользователя
    func loadCurrentUser() async {
        guard isAuthenticated else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let user = try await apiClient.getCurrentUser()
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
                
                // Просто логируем ошибку авторизации
                if case .unauthorized = networkError {
                    print("Ошибка авторизации: \(networkError)")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // Загрузка списка тренировок
    func loadWorkouts(category: WorkoutCategory? = nil, difficulty: WorkoutDifficulty? = nil) async {
        guard isAuthenticated else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let workouts = try await apiClient.getWorkouts(category: category, difficulty: difficulty)
            
            DispatchQueue.main.async {
                self.workouts = workouts
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // Загрузка списка упражнений
    func loadExercises(category: ExerciseCategory? = nil, difficulty: WorkoutDifficulty? = nil) async {
        guard isAuthenticated else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let exercises = try await apiClient.getExercises(category: category, difficulty: difficulty)
            
            DispatchQueue.main.async {
                self.exercises = exercises
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // Загрузка статистики пользователя
    func loadUserStats() async {
        guard isAuthenticated, let userId = currentUser?.id else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let stats = try await apiClient.getUserStats(userId: userId)
            
            DispatchQueue.main.async {
                self.userStats = stats
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // Загрузка достижений пользователя
    func loadAchievements() async {
        guard isAuthenticated, let userId = currentUser?.id else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let achievements = try await apiClient.getUserAchievements(userId: userId)
            
            DispatchQueue.main.async {
                self.achievements = achievements
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Обновление данных
    
    // Обновление данных пользователя
    func updateUserProfile(fullName: String? = nil, height: Int? = nil, weight: Int? = nil, age: Int? = nil) async {
        guard isAuthenticated, let userId = currentUser?.id else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        let updateRequest = APIClient.UpdateUserRequest(
            fullName: fullName,
            height: height,
            weight: weight,
            age: age
        )
        
        do {
            let updatedUser = try await apiClient.updateUser(userId: userId, userData: updateRequest)
            
            DispatchQueue.main.async {
                self.currentUser = updatedUser
                self.isLoading = false
            }
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.error = networkError
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkError.requestFailed(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Загрузка данных
    
    // Загрузка тестовых данных
    private func loadMockData() async {
        // Загрузка тестовых данных
        self.workouts = [
            WorkoutModel(
                id: "1",
                title: "Базовая техника бокса",
                description: "Тренировка для отработки основных ударов и защиты в боксе",
                difficulty: WorkoutDifficulty.beginner.rawValue,
                category: WorkoutCategory.technique.rawValue,
                duration: 30,
                caloriesBurn: 250,
                exercises: Exercise.examples.prefix(3).map { $0 },
                imageUrl: nil,
                createdAt: Date()
            ),
            WorkoutModel(
                id: "2",
                title: "Интенсивная кардио-тренировка",
                description: "Высокоинтенсивная тренировка для развития выносливости и сжигания калорий",
                difficulty: WorkoutDifficulty.advanced.rawValue,
                category: WorkoutCategory.cardio.rawValue,
                duration: 45,
                caloriesBurn: 450,
                exercises: Exercise.examples.prefix(5).map { $0 },
                imageUrl: nil,
                createdAt: Date()
            )
        ]
        self.exercises = Exercise.examples
        
        // Имитация статистики
        self.userStats = APIClient.UserStats(
            totalWorkouts: 32,
            totalTime: 1470, // 24.5 часа
            totalCalories: 12450,
            weeklyActivity: [
                APIClient.DailyActivity(day: "Пн", value: 35),
                APIClient.DailyActivity(day: "Вт", value: 42),
                APIClient.DailyActivity(day: "Ср", value: 30),
                APIClient.DailyActivity(day: "Чт", value: 55),
                APIClient.DailyActivity(day: "Пт", value: 48),
                APIClient.DailyActivity(day: "Сб", value: 60),
                APIClient.DailyActivity(day: "Вс", value: 40)
            ],
            achievements: [
                Achievement(id: "1", title: "Первые шаги", description: "Выполните 5 тренировок", progress: 5, total: 5, iconName: "figure.walk"),
                Achievement(id: "2", title: "Мастер комбо", description: "Выполните 10 комбинаций", progress: 7, total: 10, iconName: "bolt.fill")
            ]
        )
        
        self.achievements = [
            Achievement(id: "1", title: "Первые шаги", description: "Выполните 5 тренировок", progress: 5, total: 5, iconName: "figure.walk"),
            Achievement(id: "2", title: "Мастер комбо", description: "Выполните 10 комбинаций", progress: 7, total: 10, iconName: "bolt.fill"),
            Achievement(id: "3", title: "Железный кулак", description: "Выполните 100 ударов за тренировку", progress: 85, total: 100, iconName: "hand.raised.fill")
        ]
    }
}
