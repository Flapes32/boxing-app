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
        let total = exerciseProgress.reduce(0) { $0 + $1.rounds }
        return max(total, 1) // Минимум 1 раунд, даже если массив пустой
    }
    
    // Текущий общий раунд (с учетом всех упражнений)
    var currentTotalRound: Int {
        if exerciseProgress.isEmpty {
            return 1 // Если массив пуст, возвращаем 1
        }
        
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
    
    // Вычисляемые свойства для упрощения основного метода body
    private var gradientColors: [Color] {
        let primaryColor = timerModel.timerMode == .work ? Color.red : Color.green
        return [primaryColor.opacity(0.8), primaryColor.opacity(0.4)]
    }
    
    private var backgroundCircleColor: Color {
        let primaryColor = timerModel.timerMode == .work ? Color.red : Color.green
        return primaryColor.opacity(0.1)
    }
    
    private var headerTitle: String {
        timerModel.timerMode == .work ? "РАУНД \(currentTotalRound)/\(totalRounds)" : "ОТДЫХ"
    }
    
    private var headerBackgroundColor: Color {
        let primaryColor = timerModel.timerMode == .work ? Color.red : Color.green
        return primaryColor.opacity(0.3)
    }
    
    private var headerView: some View {
        Text(headerTitle)
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 25)
            .background(
                Capsule()
                    .fill(headerBackgroundColor)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var timerModeText: String {
        timerModel.timerMode == .work ? "РАБОТА" : "ОТДЫХ"
    }
    
    private var progressValue: CGFloat {
        let totalDuration = timerModel.timerMode == .work ? timerModel.workDuration : timerModel.restDuration
        return 1.0 - (CGFloat(timerModel.secondsRemaining) / CGFloat(totalDuration))
    }
    
    private var timerRingView: some View {
        ZStack {
            // Фоновое кольцо
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.1)
                .foregroundColor(.white)
            
            // Прогресс кольцо
            Circle()
                .trim(from: 0.0, to: progressValue)
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
                Text(timerModeText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 250, height: 250)
        .padding()
    }
    
    // Функция для отображения текущего упражнения
    private func currentExerciseView(exercise: WorkoutExercise) -> some View {
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
    
    // Вычисляемое свойство для отображения прогресса тренировки
    private var workoutProgressView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Прогресс тренировки:")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<exerciseProgress.count, id: \.self) { index in
                        exerciseProgressRow(index: index)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 120)
        }
    }
    
    // Функция для отображения строки прогресса упражнения
    private func exerciseProgressRow(index: Int) -> some View {
        let exercise = exerciseProgress[index]
        return HStack(alignment: .center, spacing: 8) {
            // Индикатор текущего упражнения
            Circle()
                .fill(index == currentExerciseIndex ? Color.blue : Color.clear)
                .frame(width: 8, height: 8)
            
            // Название упражнения
            Text(exercise.exercise.name)
                .font(.subheadline)
                .foregroundColor(index == currentExerciseIndex ? .white : .gray)
                .lineLimit(1)
                .frame(minWidth: 80, maxWidth: .infinity, alignment: .leading)
            
            // Индикаторы раундов
            exerciseRoundIndicators(exercise: exercise, index: index)
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
    
    // Функция для отображения индикаторов раундов
    private func exerciseRoundIndicators(exercise: WorkoutExercise, index: Int) -> some View {
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
    
    // Вычисляемое свойство для навигации по упражнениям
    private var exerciseNavigationView: some View {
        HStack(spacing: 20) {
            // Кнопка назад
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
            
            // Текущая позиция
            Text("\(currentExerciseIndex + 1)/\(exerciseProgress.count)")
                .font(.headline)
                .foregroundColor(.white)
            
            // Кнопка вперед
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
            .disabled(currentExerciseIndex >= exerciseProgress.count - 1)
            .opacity(currentExerciseIndex >= exerciseProgress.count - 1 ? 0.5 : 1.0)
        }
    }
    
    // Вычисляемое свойство для кнопок управления таймером
    private var timerControlsView: some View {
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
    }
    
    // Кнопка возврата назад
    private var backButtonView: some View {
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
    }
    
    var body: some View {
        ZStack {
            // Фоновый градиент в зависимости от режима
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Фоновые круги для дизайна
            Circle()
                .fill(backgroundCircleColor)
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(backgroundCircleColor)
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 200)
            
            VStack(spacing: 30) {
                // Заголовок с анимированным фоном
                headerView
                
                // Текущее упражнение
                if let exercise = currentExercise {
                    currentExerciseView(exercise: exercise)
                }
                
                // Таймер с анимированным кольцом
                timerRingView
                
                // Список всех упражнений с прогрессом
                if !exerciseProgress.isEmpty {
                    workoutProgressView
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                }
                
                // Навигация по упражнениям
                exerciseNavigationView
                    .padding(.vertical, 10)
                
                // Кнопки управления с улучшенным дизайном
                timerControlsView
                    .padding(.vertical, 10)
                
                Spacer()
                
                // Кнопка возврата с улучшенным дизайном
                backButtonView
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
        .onChange(of: timerModel.secondsRemaining) { newValue in
            // Когда таймер достигает 0 и мы в режиме работы, увеличиваем счетчик выполненных раундов
            if newValue == 0 && timerModel.timerMode == .work {
                completeCurrentRound()
            }
        }
    }
    
    // Функция для отметки текущего раунда как выполненного
    func completeCurrentRound() {
        guard currentExerciseIndex < exerciseProgress.count else { return }
        
        // Увеличиваем счетчик текущего раунда
        currentRoundIndex += 1
        
        // Если все раунды текущего упражнения выполнены, переходим к следующему упражнению
        if currentRoundIndex >= exerciseProgress[currentExerciseIndex].rounds {
            currentRoundIndex = 0
            currentExerciseIndex += 1
            
            // Если все упражнения выполнены, отмечаем тренировку как завершенную
            if currentExerciseIndex >= exerciseProgress.count {
                workoutCompleted = true
                sessionDuration = Int(Date().timeIntervalSince(sessionStartTime))
                
                // Здесь можно добавить логику для сохранения результатов тренировки
                // и отображения экрана завершения
                
                // Возвращаемся к первому упражнению для возможности повторения
                currentExerciseIndex = 0
            }
        }
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
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
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
        
        // Инициализация состояний из модели
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
                    Text("Настройки таймера")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Настройка времени работы
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Время работы")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("\(Int(workMinutes)) мин")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Slider(value: $workMinutes, in: 0...10, step: 1)
                                    .accentColor(.red)
                            }
                            
                            VStack {
                                Text("\(Int(workSeconds)) сек")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Slider(value: $workSeconds, in: 0...59, step: 5)
                                    .accentColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.2))
                    .cornerRadius(15)
                    
                    // Настройка времени отдыха
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Время отдыха")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("\(Int(restMinutes)) мин")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Slider(value: $restMinutes, in: 0...5, step: 1)
                                    .accentColor(.green)
                            }
                            
                            VStack {
                                Text("\(Int(restSeconds)) сек")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Slider(value: $restSeconds, in: 0...59, step: 5)
                                    .accentColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.2))
                    .cornerRadius(15)
                    
                    // Настройка количества раундов
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Количество раундов")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Slider(value: $rounds, in: 1...20, step: 1)
                                .accentColor(.blue)
                            
                            Text("\(Int(rounds))")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 40)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.2))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    // Кнопка сохранения
                    Button(action: {
                        // Сохраняем настройки в модель
                        timerModel.workDuration = Int(workMinutes) * 60 + Int(workSeconds)
                        timerModel.restDuration = Int(restMinutes) * 60 + Int(restSeconds)
                        timerModel.totalRounds = Int(rounds)
                        
                        // Сбрасываем таймер с новыми настройками
                        timerModel.resetTimer()
                        
                        // Закрываем окно настроек
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Сохранить настройки")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            })
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(workoutExercises: [
            WorkoutExercise(exercise: ExerciseDatabase.exercises[0], rounds: 3),
            WorkoutExercise(exercise: ExerciseDatabase.exercises[1], rounds: 2),
            WorkoutExercise(exercise: ExerciseDatabase.exercises[2], rounds: 4)
        ])
    }
}
