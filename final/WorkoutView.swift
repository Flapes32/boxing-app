import SwiftUI
import RealmSwift

struct WorkoutView: View {
    @State private var showingAddWorkout = false
    @State private var selectedWorkout = ""
    @State private var showingTimer = false
    @State private var searchText = ""
    @State private var selectedLevel = "Все"
    @State private var selectedCategory = "Все"
    @State private var workoutExercises: [WorkoutExercise] = []
    @State private var showingRoundsDialog = false
    @State private var tempExercise: Exercise? = nil
    @State private var numberOfRounds: Int = 1
    
    // Уровни сложности
    let levels = ["Все", "Начинающий", "Средний", "Продвинутый", "Профессионал"]
    
    // Категории упражнений
    let categories = ["Все", "Разминка", "Техника", "Силовые", "Кардио", "Заминка", "Растяжка", "Комбинации"]
    
    // Данные тренировок из базы данных упражнений
    let workouts: [WorkoutUI] = ExerciseDatabase.exercises.map { exercise in
        let category = exercise.category.rawValue
        let level = exercise.difficulty.rawValue
        let duration = exercise.duration ?? 0
        let repetitions = exercise.repetitions ?? 0
        let sets = exercise.sets ?? 0
        
        let durationText: String
        if let duration = exercise.duration {
            durationText = "\(duration) сек"
        } else if let repetitions = exercise.repetitions, let sets = exercise.sets {
            durationText = "\(sets) × \(repetitions)"
        } else {
            durationText = "Произвольно"
        }
        
        return WorkoutUI(
            name: exercise.name,
            description: exercise.description,
            category: category,
            level: level,
            duration: duration,
            repetitions: repetitions,
            sets: sets,
            format: exercise.format,
            tips: exercise.tips,
            commonMistakes: exercise.commonMistakes,
            equipment: exercise.equipment
        )
    }
    
    // Фильтрованные тренировки
    var filteredWorkouts: [WorkoutUI] {
        workouts.filter { workout in
            let levelMatch = selectedLevel == "Все" || workout.level == selectedLevel
            let categoryMatch = selectedCategory == "Все" || workout.category == selectedCategory
            let searchMatch = searchText.isEmpty || workout.name.localizedCaseInsensitiveContains(searchText) ||
                              workout.description.localizedCaseInsensitiveContains(searchText)
            
            return levelMatch && categoryMatch && searchMatch
        }
    }
    
    // Функция для проверки, выбрано ли упражнение
    func isWorkoutSelected(_ name: String) -> Bool {
        workoutExercises.contains(where: { $0.exercise.name == name })
    }
    
    // Функция для добавления упражнения в список
    func addExercise(_ exercise: Exercise, rounds: Int) {
        let workoutExercise = WorkoutExercise(exercise: exercise, rounds: rounds)
        workoutExercises.append(workoutExercise)
    }
    
    // Функция для удаления упражнения из списка
    func removeWorkoutExercise(_ workoutExercise: WorkoutExercise) {
        if let index = workoutExercises.firstIndex(where: { $0.id == workoutExercise.id }) {
            workoutExercises.remove(at: index)
        }
    }
    
    // Функция для обработки нажатия на упражнение
    func handleExerciseTap(_ exercise: Exercise) {
        if isWorkoutSelected(exercise.name) {
            // Если упражнение уже выбрано, удаляем его
            if let index = workoutExercises.firstIndex(where: { $0.exercise.name == exercise.name }) {
                workoutExercises.remove(at: index)
            }
        } else {
            // Если упражнение не выбрано, показываем диалог для выбора количества раундов
            tempExercise = exercise
            numberOfRounds = 1
            showingRoundsDialog = true
        }
    }
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск видео...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Фильтры уровня сложности
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(levels, id: \.self) { level in
                            FilterButton(title: level, isSelected: selectedLevel == level) {
                                selectedLevel = level
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                // Фильтры категорий
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            FilterButton(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 15)
                
                // Список тренировок
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCard(workout: workout, isSelected: isWorkoutSelected(workout.name))
                                .onTapGesture {
                                    if let exercise = ExerciseDatabase.exercises.first(where: { $0.name == workout.name }) {
                                        handleExerciseTap(exercise)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Выбранные упражнения
                if !workoutExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Выбранные упражнения: \(workoutExercises.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(workoutExercises, id: \.id) { workoutExercise in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(workoutExercise.exercise.name)
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                            
                                            Text("\(workoutExercise.rounds) раунд(ов)")
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.caption)
                                        }
                                        
                                        Button(action: {
                                            removeWorkoutExercise(workoutExercise)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Кнопка начать тренировку
                Button(action: {
                    if !workoutExercises.isEmpty {
                        showingTimer = true
                    }
                }) {
                    Text("Начать тренировку")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(!workoutExercises.isEmpty ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(workoutExercises.isEmpty)
                .padding(.horizontal)
                .padding(.vertical, 15)
            }
        }
        .navigationTitle("Тренировки")
        .navigationBarTitleDisplayMode(.large)
        .alert("Выберите количество раундов", isPresented: $showingRoundsDialog) {
            TextField("Количество раундов", value: $numberOfRounds, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            
            Button("Отмена", role: .cancel) {
                tempExercise = nil
            }
            
            Button("Добавить") {
                if let exercise = tempExercise, numberOfRounds > 0 {
                    addExercise(exercise, rounds: numberOfRounds)
                }
                tempExercise = nil
            }
        } message: {
            if let exercise = tempExercise {
                Text("Упражнение: \(exercise.name)\n\nУкажите, сколько раундов этого упражнения вы хотите добавить в тренировку")
            } else {
                Text("")
            }
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView(
                exerciseName: selectedWorkout,
                onSave: { repetitions in
                    // Находим упражнение по имени
                    if let exercise = ExerciseDatabase.exercises.first(where: { $0.name == selectedWorkout }) {
                        // Сохраняем запись в базу данных
                        WorkoutRecordService.shared.saveWorkoutRecord(
                            exerciseId: exercise.id,
                            exerciseName: exercise.name,
                            repetitions: repetitions
                        )
                        print("Saved workout: \(selectedWorkout) with \(repetitions) repetitions")
                    }
                    showingAddWorkout = false
                }
            )
        }
        .fullScreenCover(isPresented: $showingTimer) {
            NavigationView {
                TimerView(workoutExercises: workoutExercises)
            }
        }
    }
}

// Модель тренировки для отображения в UI
struct WorkoutUI: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let category: String
    let level: String
    let duration: Int // в секундах
    let repetitions: Int?
    let sets: Int?
    let format: String
    let tips: [String]
    let commonMistakes: [String]
    let equipment: [String]
    
    init(name: String, description: String, category: String, level: String, duration: Int, repetitions: Int? = nil, sets: Int? = nil, format: String = "", tips: [String] = [], commonMistakes: [String] = [], equipment: [String] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.level = level
        self.duration = duration
        self.repetitions = repetitions
        self.sets = sets
        self.format = format
        self.tips = tips
        self.commonMistakes = commonMistakes
        self.equipment = equipment
    }
}

// Компонент кнопки фильтра
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue : Color(.systemGray6).opacity(0.3))
                .cornerRadius(20)
        }
    }
}

// Компонент карточки тренировки
struct WorkoutCard: View {
    let workout: WorkoutUI
    let isSelected: Bool
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(workout.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack(spacing: 15) {
                // Категория
                HStack(spacing: 5) {
                    Image(systemName: categoryIcon(workout.category))
                        .foregroundColor(categoryColor(workout.category))
                    Text(workout.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Уровень сложности
                HStack(spacing: 5) {
                    Image(systemName: "speedometer")
                        .foregroundColor(.yellow)
                    Text(workout.level)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Формат (длительность или повторения)
                HStack(spacing: 5) {
                    Image(systemName: workout.repetitions != nil ? "number" : "clock")
                        .foregroundColor(.blue)
                    Text(workout.format)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if showDetails {
                VStack(alignment: .leading, spacing: 10) {
                    if !workout.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Советы:")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            ForEach(workout.tips, id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if !workout.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Распространенные ошибки:")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            ForEach(workout.commonMistakes, id: \.self) { mistake in
                                Text("• \(mistake)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if !workout.equipment.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Необходимое оборудование:")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            ForEach(workout.equipment, id: \.self) { item in
                                Text("• \(item)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
            
            Button(action: {
                withAnimation {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    Text(showDetails ? "Скрыть детали" : "Показать детали")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(10)
    }
}

// Цвет в зависимости от категории
func categoryColor(_ category: String) -> Color {
    switch category {
    case "Разминка":
        return .orange
    case "Техника":
        return .blue
    case "Силовые":
        return .red
    case "Кардио":
        return .pink
    case "Заминка":
        return .green
    case "Растяжка":
        return .purple
    case "Комбинации":
        return .yellow
    default:
        return .gray
    }
}

// Иконка в зависимости от категории
func categoryIcon(_ category: String) -> String {
    switch category {
    case "Разминка":
        return "flame.fill"
    case "Техника":
        return "figure.boxing"
    case "Силовые":
        return "dumbbell.fill"
    case "Кардио":
        return "heart.fill"
    case "Заминка":
        return "wind"
    case "Растяжка":
        return "figure.flexibility"
    case "Комбинации":
        return "figure.boxing.motion"
    default:
        return "questionmark.circle"
    }
}
