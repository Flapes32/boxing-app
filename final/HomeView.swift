import SwiftUI

struct HomeView: View {
    @State private var showingTimer = false
    @State private var pulsate = false
    
    // Сервис данных для работы с API
    @EnvironmentObject private var dataService: DataService
    
    // Данные пользователя
    @State private var userName = "Александр"
    @State private var userRank = "Новичок"
    @State private var userLevel = 1
    @State private var userHeight = 180
    @State private var userWeight = 75
    @State private var userAge = 28
    @State private var userTrainingDays = 15
    @State private var userTotalWorkouts = 32
    
    // Статистика тренировок
    @State private var workoutStats = [
        StatItem(title: "Тренировки", value: "32", icon: "dumbbell.fill", color: .blue),
        StatItem(title: "Калории", value: "12,450", icon: "flame.fill", color: .orange),
        StatItem(title: "Время", value: "24ч 30м", icon: "clock.fill", color: .green),
        StatItem(title: "Серии", value: "128", icon: "repeat", color: .purple)
    ]
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Профиль пользователя
                    HStack(spacing: 15) {
                        // Аватар пользователя
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .scaleEffect(pulsate ? 1.1 : 1.0)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulsate)
                            
                            Circle()
                                .fill(Color.yellow.opacity(0.6))
                                .frame(width: 65, height: 65)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .onAppear { pulsate = true }
                        
                        // Информация о пользователе
                        VStack(alignment: .leading, spacing: 5) {
                            Text(userName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text(userRank)
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                
                                Text("• Ур. \(userLevel)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("\(userTrainingDays) дней тренировок")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Физические параметры
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Физические параметры")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack(spacing: 8) {
                            // Рост
                            VStack {
                                Text("Рост")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(userHeight) см")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(15)
                            
                            // Вес
                            VStack {
                                Text("Вес")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(userWeight) кг")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(15)
                            
                            // Возраст
                            VStack {
                                Text("Возраст")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(userAge)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Статистика тренировок
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Статистика тренировок")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(workoutStats) { stat in
                                StatisticCard(statItem: stat)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Кнопка таймера
                    Button(action: {
                        showingTimer = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(height: 60)
                                .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            HStack(spacing: 15) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                
                                Text("НАЧАТЬ ТРЕНИРОВКУ")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    // Кнопка выхода из аккаунта
                    Button(action: {
                        // Выход из аккаунта
                        dataService.logout()
                    }) {
                        HStack {
                            Spacer()
                            
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.white)
                                
                                Text("Выйти из аккаунта")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    
                    // Добавляем отступ снизу для таб-бара
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingTimer) {
            NavigationView {
                TimerView(workoutExercises: [])
            }
        }
    }
}

// Модель статистики
struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

// Компонент карточки статистики
struct StatisticCard: View {
    let statItem: StatItem
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(statItem.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: statItem.icon)
                    .font(.system(size: 18))
                    .foregroundColor(statItem.color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(statItem.value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(statItem.title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(DataService.shared)
        }
    }
}


