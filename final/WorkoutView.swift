import SwiftUI

struct WorkoutView: View {
    @State private var showingAddWorkout = false
    @State private var selectedWorkout = ""
    @State private var showingTimer = false
    @State private var searchText = ""
    @State private var selectedLevel = "Все"
    @State private var selectedCategory = "Все"
    
    // Уровни сложности
    let levels = ["Все", "Начинающий", "Средний", "Продвинутый"]
    
    // Категории упражнений
    let categories = ["Все", "Кардио", "Силовые", "Гибкость", "Функциональные"]
    
    // Данные тренировок
    let workouts = [
        WorkoutUI(name: "Бег", description: "Кардио тренировка для выносливости", category: "Кардио", level: "Начинающий", duration: 600),
        WorkoutUI(name: "Растяжка", description: "Улучшает гибкость", category: "Гибкость", level: "Начинающий", duration: 300),
        WorkoutUI(name: "Отжимания", description: "Силовая тренировка для верхней части тела", category: "Силовые", level: "Средний", duration: 450),
        WorkoutUI(name: "Бой с тенью", description: "Техника и координация", category: "Функциональные", level: "Продвинутый", duration: 480),
        WorkoutUI(name: "Скакалка", description: "Кардио и координация", category: "Кардио", level: "Начинающий", duration: 420)
    ]
    
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
    let id = UUID()
    let name: String
    let description: String
    let category: String
    let level: String
    let duration: Int // в секундах
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(workout.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
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
                
                // Длительность
                Text("\(workout.duration) сек")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.15))
        .cornerRadius(12)
    }
    
    // Цвет в зависимости от категории
    func categoryColor(_ category: String) -> Color {
        switch category {
        case "Кардио": return .red
        case "Силовые": return .blue
        case "Гибкость": return .green
        case "Функциональные": return .orange
        default: return .gray
        }
    }
    
    // Цвет в зависимости от уровня
    func levelColor(_ level: String) -> Color {
        switch level {
        case "Начинающий": return .green
        case "Средний": return .yellow
        case "Продвинутый": return .orange
        default: return .gray
        }
    }
}

#Preview {
    NavigationView {
        WorkoutView()
    }
}

