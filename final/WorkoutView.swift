import SwiftUI

struct WorkoutView: View {
    @State private var showingAddWorkout = false
    @State private var selectedWorkout = ""
    @State private var showingTimer = false
    @State private var searchText = ""
    @State private var selectedLevel = "Все"
    @State private var selectedCategory = "Все"
    
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
                            WorkoutCard(workout: workout)
                                .onTapGesture {
                                    selectedWorkout = workout.name
                                    showingAddWorkout = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Кнопка начать тренировку
                Button(action: {
                    showingTimer = true
                }) {
                    Text("Начать тренировку")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
            }
        }
        .navigationTitle("Тренировки")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView(
                exerciseName: selectedWorkout,
                onSave: { repetitions in
                    print("Saved workout: \(selectedWorkout) with \(repetitions) repetitions")
                    showingAddWorkout = false
                }
            )
        }
        .fullScreenCover(isPresented: $showingTimer) {
            NavigationView {
                TimerView()
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
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue : Color(.systemGray6).opacity(0.3))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .cornerRadius(20)
        }
    }
}

// Компонент карточки тренировки
struct WorkoutCard: View {
    let workout: WorkoutUI
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(workout.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                // Категория
                Text(workout.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor(workout.category).opacity(0.2))
                    .foregroundColor(categoryColor(workout.category))
                    .cornerRadius(4)
                
                // Уровень
                Text(workout.level)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelColor(workout.level).opacity(0.2))
                    .foregroundColor(levelColor(workout.level))
                    .cornerRadius(4)
                
                Spacer()
                
                // Формат упражнения
                Text(workout.format.isEmpty ? "\(workout.duration) сек" : workout.format)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(Color.blue)
                    .cornerRadius(4)
            }
            
            if showDetails {
                VStack(alignment: .leading, spacing: 10) {
                    if !workout.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Советы:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ForEach(workout.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.gray)
                                    Text(tip)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    if !workout.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Распространенные ошибки:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ForEach(workout.commonMistakes, id: \.self) { mistake in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.gray)
                                    Text(mistake)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    if !workout.equipment.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Необходимое оборудование:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            ForEach(workout.equipment, id: \.self) { item in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.gray)
                                    Text(item)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
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
    case "Кардио": return .red
    case "Силовые": return .blue
    case "Растяжка": return .green
    case "Техника": return .purple
    case "Комбинации": return .orange
    case "Разминка": return .yellow
    case "Заминка": return .mint
    default: return .gray
    }
}

// Цвет в зависимости от уровня
func levelColor(_ level: String) -> Color {
    switch level {
    case "Начинающий": return .green
    case "Средний": return .yellow
    case "Продвинутый": return .orange
    case "Профессионал": return .red
    default: return .gray
    }
}

#Preview {
    NavigationView {
        WorkoutView()
    }
}

