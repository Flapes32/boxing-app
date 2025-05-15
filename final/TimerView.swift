import SwiftUI

struct TimerView: View {
    @StateObject private var timerModel = BoxingTimer()
    @State private var showingCustomizationView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var animateRing = false
    
    // Текущий индекс упражнения и раунда
    @State private var currentExerciseIndex = 0
    @State private var currentRoundIndex = 0
    
    // Массив упражнений с количеством раундов
    let workoutExercises: [WorkoutExercise]
    
    // Массив для отслеживания выполненных раундов
    @State private var exerciseProgress: [WorkoutExercise]
    
    // Состояние завершения тренировки
    @State private var workoutCompleted = false
    @State private var sessionStartTime = Date()
    @State private var sessionDuration: Int = 0
    
    // Текущее упражнение
    var currentExercise: WorkoutExercise? {
        guard !exerciseProgress.isEmpty, currentExerciseIndex < exerciseProgress.count else { return nil }
        return exerciseProgress[currentExerciseIndex]
    }
    
    // Общее количество раундов всех упражнений
    var totalRounds: Int {
        exerciseProgress.reduce(0) { $0 + $1.rounds }
    }
    
    // Текущий общий раунд (с учетом всех упражнений)
    var currentTotalRound: Int {
        var total = currentRoundIndex
        for i in 0..<currentExerciseIndex {
            total += exerciseProgress[i].rounds
        }
        return total + 1
    }
    
    init(workoutExercises: [WorkoutExercise]) {
        self.workoutExercises = workoutExercises
        // Создаем копию упражнений для отслеживания прогресса
        _exerciseProgress = State(initialValue: workoutExercises)
        _sessionStartTime = State(initialValue: Date())
    }
    
    var body: some View {
        ZStack {
            // Фоновый градиент в зависимости от режима
            LinearGradient(
                gradient: Gradient(colors: [
                    timerModel.timerMode == .work ? Color.red.opacity(0.8) : Color.green.opacity(0.8),
                    timerModel.timerMode == .work ? Color.red.opacity(0.4) : Color.green.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Фоновые круги для дизайна
            Circle()
                .fill(timerModel.timerMode == .work ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(timerModel.timerMode == .work ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 200)
            
            VStack(spacing: 30) {
                // Заголовок с анимированным фоном
                Text(timerModel.timerMode == .work ? "РАУНД \(currentTotalRound)/\(totalRounds)" : "ОТДЫХ")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 25)
                    .background(
                        Capsule()
                            .fill(timerModel.timerMode == .work ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Текущее упражнение
                if let exercise = currentExercise {
                    VStack(spacing: 5) {
                        Text("ТЕКУЩЕЕ УПРАЖНЕНИЕ")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(exercise.exercise.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text(exercise.exercise.format)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Раунд \(currentRoundIndex + 1) из \(exercise.rounds)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
                
                // Таймер с анимированным кольцом
                ZStack {
                    // Фоновое кольцо
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.1)
                        .foregroundColor(.white)
                    
                    // Прогресс кольцо
                    Circle()
                        .trim(from: 0.0, to: 1.0 - (Double(timerModel.secondsRemaining) / Double(timerModel.timerMode == .work ? timerModel.workDuration : timerModel.restDuration)))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.linear(duration: 1.0), value: timerModel.secondsRemaining)
                    
                    VStack(spacing: 5) {
                        // Время
                        Text(timerModel.formatTime())
                            .font(.system(size: 70, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Режим
                        Text(timerModel.timerMode == .work ? "РАБОТА" : "ОТДЫХ")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                
                // Список всех упражнений с прогрессом
                if !exerciseProgress.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Прогресс тренировки:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(0..<exerciseProgress.count, id: \.self) { index in
                                    let exercise = exerciseProgress[index]
                                    HStack(alignment: .center, spacing: 8) {
                                        // Индикатор текущего упражнения
                                        if index == currentExerciseIndex {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 8, height: 8)
                                        } else {
                                            Circle()
                                                .fill(Color.clear)
                                                .frame(width: 8, height: 8)
                                        }
                                        
                                        // Название упражнения
                                        Text(exercise.exercise.name)
                                            .font(.subheadline)
                                            .foregroundColor(index == currentExerciseIndex ? .white : .gray)
                                            .lineLimit(1)
                                            .frame(minWidth: 80, maxWidth: .infinity, alignment: .leading)
                                        
                                        // Индикаторы раундов
                                        HStack(spacing: 3) {
                                            ForEach(0..<min(exercise.rounds, 5), id: \.self) { roundIndex in
                                                let isCompleted = index < currentExerciseIndex || (index == currentExerciseIndex && roundIndex < currentRoundIndex)
                                                
                                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(isCompleted ? .green : .gray)
                                                    .font(.system(size: 12))
                                            }
                                            
                                            // Если больше 5 раундов, показываем текст
                                            if exercise.rounds > 5 {
                                                Text("+\(exercise.rounds - 5)")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(index == currentExerciseIndex ? Color(.systemGray6).opacity(0.3) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        currentExerciseIndex = index
                                        currentRoundIndex = 0
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 120)
                    }
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                    
                    // Навигация по упражнениям
                    HStack(spacing: 20) {
                        Button(action: {
                            if currentExerciseIndex > 0 {
                                currentExerciseIndex -= 1
                                currentRoundIndex = 0
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .disabled(currentExerciseIndex == 0)
                        .opacity(currentExerciseIndex == 0 ? 0.5 : 1.0)
                        
                        Text("\(currentExerciseIndex + 1)/\(exerciseProgress.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            if currentExerciseIndex < exerciseProgress.count - 1 {
                                currentExerciseIndex += 1
                                currentRoundIndex = 0
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .disabled(currentExerciseIndex == exerciseProgress.count - 1)
                        .opacity(currentExerciseIndex == exerciseProgress.count - 1 ? 0.5 : 1.0)
                    }
                    .padding(.vertical, 5)
                }
                
                // Кнопки управления с улучшенным дизайном
                HStack(spacing: 40) {
                    // Кнопка сброса текущего раунда
                    TimerButton(icon: "arrow.counterclockwise", action: {
                        timerModel.resetCurrentRound()
                    })
                    
                    // Кнопка старт/пауза (увеличенная)
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Button(action: {
                            if timerModel.timerState == .running {
                                timerModel.pauseTimer()
                            } else {
                                if timerModel.timerState == .stopped {
                                    timerModel.startTimer()
                                } else {
                                    timerModel.resumeTimer()
                                }
                            }
                        }) {
                            Image(systemName: timerModel.timerState == .running ? "pause.fill" : "play.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Кнопка выхода к настройкам таймера
                    TimerButton(icon: "gear", action: {
                        timerModel.pauseTimer()
                        showingCustomizationView = true
                    })
                }
                
                Spacer()
                
                // Кнопка возврата с улучшенным дизайном
                Button(action: {
                    timerModel.pauseTimer()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                        Text("ВЕРНУТЬСЯ")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .sheet(isPresented: $showingCustomizationView) {
            TimerCustomizationView(timerModel: timerModel)
        }
        .navigationBarHidden(true)
        .onAppear {
            animateRing = true
            // Установка общего количества раундов в соответствии с общим количеством раундов всех упражнений
            timerModel.totalRounds = totalRounds
            sessionStartTime = Date()
        }
        .onChange(of: timerModel.secondsRemaining) { oldValue, newValue in
            // Когда таймер достигает 0 и мы в режиме работы, увеличиваем счетчик выполненных раундов
            if newValue == 0 && oldValue > 0 && timerModel.timerMode == .work {
                completeCurrentRound()
            }
        }
        .alert("Тренировка завершена!", isPresented: $workoutCompleted) {
            Button("Сохранить результаты") {
                saveWorkoutResults()
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Закрыть", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Вы успешно завершили все упражнения! Хотите сохранить результаты тренировки?")
        }
    }
    
    // Функция для отметки текущего раунда как выполненного
    func completeCurrentRound() {
        guard currentExerciseIndex < exerciseProgress.count else { return }
        
        // Увеличиваем счетчик выполненных раундов для текущего упражнения
        currentRoundIndex += 1
        exerciseProgress[currentExerciseIndex].completedRounds += 1
        
        // Если все раунды текущего упражнения выполнены, переходим к следующему упражнению
        if currentRoundIndex >= exerciseProgress[currentExerciseIndex].rounds {
            // Переходим к следующему упражнению
            if currentExerciseIndex < exerciseProgress.count - 1 {
                currentExerciseIndex += 1
                currentRoundIndex = 0
            } else {
                // Если это было последнее упражнение, проверяем, все ли упражнения завершены
                checkWorkoutCompletion()
            }
        }
    }
    
    // Проверка завершения всей тренировки
    func checkWorkoutCompletion() {
        let allCompleted = exerciseProgress.allSatisfy { exercise in
            exercise.completedRounds >= exercise.rounds
        }
        
        if allCompleted {
            // Рассчитываем общую продолжительность тренировки
            sessionDuration = Int(Date().timeIntervalSince(sessionStartTime))
            
            // Останавливаем таймер
            timerModel.pauseTimer()
            
            // Показываем сообщение о завершении
            workoutCompleted = true
        }
    }
    
    // Сохранение результатов тренировки в базу данных
    func saveWorkoutResults() {
        // Сохраняем сессию тренировки с результатами
        let _ = WorkoutSessionService.shared.saveWorkoutSession(
            exercises: exerciseProgress,
            totalDuration: sessionDuration
        )
        
        print("Сохранены результаты тренировки продолжительностью \(sessionDuration) сек")
    }
}

// Компонент кнопки таймера
struct TimerButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct TimerCustomizationView: View {
    @ObservedObject var timerModel: BoxingTimer
    @Environment(\.presentationMode) var presentationMode
    
    @State private var workMinutes: Double
    @State private var workSeconds: Double
    @State private var restMinutes: Double
    @State private var restSeconds: Double
    @State private var rounds: Double
    
    init(timerModel: BoxingTimer) {
        self.timerModel = timerModel
        _workMinutes = State(initialValue: Double(timerModel.workDuration / 60))
        _workSeconds = State(initialValue: Double(timerModel.workDuration % 60))
        _restMinutes = State(initialValue: Double(timerModel.restDuration / 60))
        _restSeconds = State(initialValue: Double(timerModel.restDuration % 60))
        _rounds = State(initialValue: Double(timerModel.totalRounds))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Настройка времени работы
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ВРЕМЯ РАБОТЫ")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("\(Int(workMinutes)) мин")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Slider(value: $workMinutes, in: 0...10, step: 1)
                                    .accentColor(.red)
                            }
                            
                            VStack {
                                Text("\(Int(workSeconds)) сек")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Slider(value: $workSeconds, in: 0...59, step: 5)
                                    .accentColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(15)
                    
                    // Настройка времени отдыха
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ВРЕМЯ ОТДЫХА")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("\(Int(restMinutes)) мин")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Slider(value: $restMinutes, in: 0...5, step: 1)
                                    .accentColor(.green)
                            }
                            
                            VStack {
                                Text("\(Int(restSeconds)) сек")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Slider(value: $restSeconds, in: 0...59, step: 5)
                                    .accentColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    // Кнопка сохранения настроек
                    Button(action: {
                        // Сохранение настроек
                        timerModel.workDuration = Int(workMinutes) * 60 + Int(workSeconds)
                        timerModel.restDuration = Int(restMinutes) * 60 + Int(restSeconds)
                        timerModel.resetTimer()
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("СОХРАНИТЬ")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationTitle("Настройки таймера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TimerView(workoutExercises: [
        WorkoutExercise(exercise: ExerciseDatabase.exercises[0], rounds: 3),
        WorkoutExercise(exercise: ExerciseDatabase.exercises[1], rounds: 2),
        WorkoutExercise(exercise: ExerciseDatabase.exercises[2], rounds: 1)
    ])
}
