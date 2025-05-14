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
    
    // Флаг авторизации
    @Published var isAuthenticated = false
    
    private init() {
        // Проверка наличия сохраненного токена при инициализации
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            NetworkManager.shared.setAuthToken(token)
            isAuthenticated = true
            
            // Загрузка данных пользователя
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    // MARK: - Аутентификация
    
    // Метод для загрузки данных пользователя
    func loadUserData() async {
        isLoading = true
        error = nil
        
        do {
            // Получаем данные аутентификации
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            // Пытаемся загрузить данные из Realm
            if let user = RealmService.shared.getUser(id: authDataResult.uid) {
                self.currentUser = user
                
                // Загружаем тренировки и достижения
                self.workouts = RealmService.shared.getUserWorkouts(userId: user.id)
                self.achievements = RealmService.shared.getUserAchievements(userId: user.id)
                
                // Настраиваем наблюдение за изменениями
                setupObservers(userId: user.id)
            } else {
                // Создаем нового пользователя в Realm
                let newUser = User(
                    id: authDataResult.uid,
                    username: "",
                    fullName: "",
                    email: authDataResult.email ?? "",
                    profileImageUrl: nil,
                    height: 0,
                    weight: 0,
                    age: 0,
                    trainingDays: 0,
                    totalWorkouts: 0,
                    rank: "Новичок",
                    level: 1,
                    joinDate: Date(),
                    isActive: true
                )
                
                try RealmService.shared.saveUser(newUser)
                self.currentUser = newUser
                setupObservers(userId: newUser.id)
            }
            
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.error = NetworkError.serverError(statusCode: 401, message: "Ошибка загрузки данных пользователя")
            self.isLoading = false
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
    
    // Метод для авторизации пользователя через Firebase
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            let _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
            await loadUserData()
            // Сбрасываем флаг загрузки после успешной авторизации
            isLoading = false
        } catch {
            self.error = NetworkError.serverError(statusCode: 401, message: "Ошибка авторизации")
            isLoading = false
        }
    }
    
    // Метод для выхода из аккаунта
    func logout() {
        do {
            // Выход из Firebase
            try AuthenticationManager.shared.signOut()
            
            // Очистка данных
            self.currentUser = nil
            self.isAuthenticated = false
            self.workouts = []
            self.exercises = []
            self.userStats = nil
            self.achievements = []
        } catch {
            print("Ошибка при выходе из аккаунта: \(error.localizedDescription)")
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
                
                // Если ошибка авторизации, выходим из системы
                if case .unauthorized = networkError {
                    self.logout()
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
