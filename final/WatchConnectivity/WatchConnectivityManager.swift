import Foundation
import WatchConnectivity
import Combine

// Менеджер для работы с WatchConnectivity на стороне iPhone
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    // Публикуемые свойства для обновления UI
    @Published var isPaired: Bool = false
    @Published var isReachable: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var latestWorkoutData: WatchWorkoutData? = nil
    @Published var isWorkoutInProgress: Bool = false
    
    // История данных тренировки для построения графиков
    @Published var workoutDataHistory: [WatchWorkoutData] = []
    
    // Максимальное количество точек данных для хранения в истории
    private let maxHistoryPoints = 100
    
    // Идентификатор текущей тренировки
    private var currentWorkoutId: String?
    
    private override init() {
        super.init()
        activateSession()
    }
    
    // Активация сессии WatchConnectivity с защитой от сбоев
    private func activateSession() {
        do {
            guard WCSession.isSupported() else {
                print("WCSession не поддерживается на этом устройстве")
                return 
            }
            
            let session = WCSession.default
            session.delegate = self
            
            // Защита от возможных сбоев при активации
            DispatchQueue.main.async {
                session.activate()
                print("WCSession активирован успешно")
            }
        } catch {
            print("Ошибка при активации WCSession: \(error.localizedDescription)")
        }
    }
    
    // Проверка доступности Apple Watch с защитой от сбоев
    func checkWatchAvailability() {
        do {
            guard WCSession.isSupported() else {
                print("WCSession не поддерживается при проверке доступности")
                return 
            }
            
            let session = WCSession.default
            
            // Безопасное получение статуса на главном потоке
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Защита от возможных сбоев при проверке статуса
                let isPaired = session.isPaired
                let isReachable = session.isReachable
                let isWatchAppInstalled = session.isWatchAppInstalled
                
                print("Статус Apple Watch: сопряжены=\(isPaired), доступны=\(isReachable), приложение установлено=\(isWatchAppInstalled)")
                
                self.isPaired = isPaired
                self.isReachable = isReachable
                self.isWatchAppInstalled = isWatchAppInstalled
            }
        } catch {
            print("Ошибка при проверке доступности Apple Watch: \(error.localizedDescription)")
        }
    }
    
    // Отправка настроек таймера на Apple Watch
    func sendTimerSettings(settings: TimerSettings) {
        guard WCSession.isSupported(), WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        do {
            // Сначала кодируем настройки таймера
            let settingsData = try JSONEncoder().encode(settings)
            // Создаем сообщение с уже закодированными данными
            let message = WatchMessage(command: .updateSettings, data: settingsData)
            let messageData = try JSONEncoder().encode(message)
            let messageDict = ["message": messageData]
            
            WCSession.default.sendMessage(messageDict, replyHandler: { reply in
                print("Timer settings sent successfully: \(reply)")
            }, errorHandler: { error in
                print("Error sending timer settings: \(error.localizedDescription)")
            })
        } catch {
            print("Error encoding timer settings: \(error.localizedDescription)")
        }
    }
    
    // Отправка упражнений на Apple Watch
    func syncExercises(exercises: [WorkoutExercise]) {
        guard WCSession.isSupported(), WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        // Преобразование WorkoutExercise в ExerciseData
        let exerciseData = exercises.map { exercise in
            ExerciseData(
                id: UUID().uuidString,
                name: exercise.exercise.name,
                rounds: exercise.rounds
            )
        }
        
        do {
            // Сначала кодируем данные упражнений
            let exercisesData = try JSONEncoder().encode(exerciseData)
            // Создаем сообщение с уже закодированными данными
            let message = WatchMessage(command: .syncExercises, data: exercisesData)
            let messageData = try JSONEncoder().encode(message)
            let messageDict = ["message": messageData]
            
            WCSession.default.sendMessage(messageDict, replyHandler: { reply in
                print("Exercises synced successfully: \(reply)")
            }, errorHandler: { error in
                print("Error syncing exercises: \(error.localizedDescription)")
            })
        } catch {
            print("Error encoding exercises: \(error.localizedDescription)")
        }
    }
    
    // Запрос данных с Apple Watch
    func requestWorkoutData() {
        guard WCSession.isSupported(), WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        do {
            let message = WatchMessage(command: .requestData)
            let messageData = try JSONEncoder().encode(message)
            let messageDict = ["message": messageData]
            
            WCSession.default.sendMessage(messageDict, replyHandler: { reply in
                print("Data request sent successfully: \(reply)")
            }, errorHandler: { error in
                print("Error requesting data: \(error.localizedDescription)")
            })
        } catch {
            print("Error encoding data request: \(error.localizedDescription)")
        }
    }
    
    // Отправка команды на запуск тренировки
    func startWorkout() {
        sendCommand(.startWorkout)
        currentWorkoutId = UUID().uuidString
        isWorkoutInProgress = true
    }
    
    // Отправка команды на паузу тренировки
    func pauseWorkout() {
        sendCommand(.pauseWorkout)
    }
    
    // Отправка команды на возобновление тренировки
    func resumeWorkout() {
        sendCommand(.resumeWorkout)
    }
    
    // Отправка команды на остановку тренировки
    func stopWorkout() {
        sendCommand(.stopWorkout)
        currentWorkoutId = nil
        isWorkoutInProgress = false
    }
    
    // Общий метод для отправки команд
    private func sendCommand(_ command: WatchCommand) {
        guard WCSession.isSupported(), WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        do {
            let message = WatchMessage(command: command)
            let messageData = try JSONEncoder().encode(message)
            let messageDict = ["message": messageData]
            
            WCSession.default.sendMessage(messageDict, replyHandler: { reply in
                print("Command \(command) sent successfully: \(reply)")
            }, errorHandler: { error in
                print("Error sending command \(command): \(error.localizedDescription)")
            })
        } catch {
            print("Error encoding command \(command): \(error.localizedDescription)")
        }
    }
    
    // Обработка полученных данных тренировки
    private func processWorkoutData(_ data: WatchWorkoutData) {
        DispatchQueue.main.async {
            self.latestWorkoutData = data
            self.isWorkoutInProgress = data.isInProgress
            
            // Добавляем данные в историю
            self.workoutDataHistory.append(data)
            
            // Ограничиваем размер истории
            if self.workoutDataHistory.count > self.maxHistoryPoints {
                self.workoutDataHistory.removeFirst(self.workoutDataHistory.count - self.maxHistoryPoints)
            }
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isReachable = session.isReachable
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        // Реактивация сессии
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleReceivedMessage(message)
        replyHandler(["status": "received"])
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        guard let messageData = message["message"] as? Data else {
            print("Invalid message format")
            return
        }
        
        do {
            let watchMessage = try JSONDecoder().decode(WatchMessage.self, from: messageData)
            
            switch watchMessage.command {
            case .requestData:
                // Запрос данных с часов - ничего не делаем
                break
                
            default:
                // Обработка данных тренировки
                if let data = watchMessage.data,
                   let workoutData = try? JSONDecoder().decode(WatchWorkoutData.self, from: data) {
                    processWorkoutData(workoutData)
                }
            }
        } catch {
            print("Error decoding message: \(error.localizedDescription)")
        }
    }
}
