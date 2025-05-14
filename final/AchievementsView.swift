import SwiftUI

struct AchievementsView: View {
    // Модель данных пользователя
    @State private var currentRank = "Новичок"
    @State private var currentLevel = 1
    @State private var progressToNextRank = 0.4 // 40% прогресса до следующего ранга
    
    // Достижения пользователя
    @State private var achievements = [
        AchievementUI(id: "1", title: "Первые шаги", description: "Выполните 5 тренировок", progress: 3, total: 5, iconName: "figure.walk"),
        AchievementUI(id: "2", title: "Мастер комбо", description: "Выполните 10 комбинаций", progress: 7, total: 10, iconName: "bolt.fill"),
        AchievementUI(id: "3", title: "Железная выносливость", description: "Тренируйтесь 30 минут без перерыва", progress: 20, total: 30, iconName: "heart.fill"),
        AchievementUI(id: "4", title: "Скоростной боксер", description: "Выполните 50 ударов за минуту", progress: 35, total: 50, iconName: "speedometer")
    ]
    
    // Ранги пользователя
    let ranks = ["Новичок", "Любитель", "Мастер", "Профессионал"]
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                Text("Достижения")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Секция текущего ранга
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ваш текущий ранг")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Карточки рангов
                    HStack(spacing: 15) {
                        // Текущий ранг (активный)
                        RankCard(
                            rank: "Новичок",
                            level: "Уровень 1",
                            isActive: true
                        )
                        
                        // Следующий ранг (неактивный)
                        RankCard(
                            rank: "Любитель",
                            level: "Уровень 2",
                            isActive: false
                        )
                    }
                    .padding(.horizontal)
                    
                    // Прогресс до следующего ранга
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Прогресс до следующего ранга")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Прогресс-бар
                        ZStack(alignment: .leading) {
                            // Фон прогресс-бара
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(.systemGray6).opacity(0.3))
                                .frame(height: 10)
                            
                            // Заполненная часть прогресс-бара
                            RoundedRectangle(cornerRadius: 5)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: UIScreen.main.bounds.width * 0.8 * progressToNextRank, height: 10)
                        }
                        
                        // Подписи к прогресс-бару
                        HStack {
                            Text("Новичок")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("Любитель")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                // Заголовок списка достижений
                Text("Достижения")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Список достижений
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(achievements, id: \.id) { achievement in
                            AchievementItemCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Модель достижения для UI
struct AchievementUI: Identifiable {
    let id: String
    let title: String
    let description: String
    let progress: Int
    let total: Int
    let iconName: String
    
    var progressPercentage: Double {
        return Double(progress) / Double(total)
    }
}

// Карточка ранга
struct RankCard: View {
    let rank: String
    let level: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.blue : Color(.systemGray6).opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isActive ? .white : .gray)
            }
            
            Text(rank)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .white : .gray)
            
            Text(level)
                .font(.caption)
                .foregroundColor(isActive ? .white.opacity(0.7) : .gray.opacity(0.7))
        }
    }
}

// Карточка достижения
struct AchievementItemCard: View {
    let achievement: AchievementUI
    
    var body: some View {
        HStack {
            // Иконка достижения
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Информация о достижении
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(achievement.progress)/\(achievement.total)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Прогресс-бар достижения
                ZStack(alignment: .leading) {
                    // Фон прогресс-бара
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray6).opacity(0.3))
                        .frame(height: 6)
                    
                    // Заполненная часть прогресс-бара
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: (UIScreen.main.bounds.width - 100) * achievement.progressPercentage, height: 6)
                }
                .padding(.top, 4)
            }
            .padding(.leading, 10)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AchievementsView()
    }
}
