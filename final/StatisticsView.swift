import SwiftUI

struct StatisticsView: View {
    // Данные для графика
    let weekData: [WorkoutData] = [
        WorkoutData(day: "Пн", value: 35),
        WorkoutData(day: "Вт", value: 42),
        WorkoutData(day: "Ср", value: 30),
        WorkoutData(day: "Чт", value: 55),
        WorkoutData(day: "Пт", value: 48),
        WorkoutData(day: "Сб", value: 60),
        WorkoutData(day: "Вс", value: 40)
    ]
    
    // Данные о здоровье
    @State private var currentHeartRate = 72
    @State private var stressLevel = 35
    @State private var sleepHours = 7.5
    
    // Рекомендации по восстановлению
    @State private var recoveryTips = [
        "Пейте больше воды",
        "Применяйте растяжку после тренировки",
        "Соблюдайте режим сна"
    ]
    
    // Состояние восстановления отмечено
    @State private var recoveryCompleted = false
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Заголовок
                        Text("Статистика")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        // График тренировок
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Активность за неделю")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // График (упрощенная версия)
                            VStack(spacing: 10) {
                                // Значения графика
                                HStack(alignment: .bottom, spacing: (UIScreen.main.bounds.width - 80) / 7) {
                                    ForEach(weekData) { item in
                                        VStack(spacing: 5) {
                                            // Столбец графика
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.green)
                                                .frame(width: 10, height: item.value * 2)
                                            
                                            // Подпись дня
                                            Text(item.day)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                
                                // Горизонтальные линии
                                VStack(spacing: 20) {
                                    ForEach([60, 40, 20, 0], id: \.self) { value in
                                        HStack {
                                            Text("\(value)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(width: 20, alignment: .trailing)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .offset(y: -140)
                                .zIndex(-1)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        // Показатели здоровья
                        VStack(spacing: 15) {
                            // Пульс
                            HealthMetricCard(
                                title: "Текущий пульс",
                                value: "\(currentHeartRate) bpm",
                                icon: "heart.fill",
                                color: .green
                            )
                            
                            // Уровень стресса
                            HealthMetricCard(
                                title: "Уровень стресса",
                                value: "\(stressLevel)%",
                                icon: "brain.head.profile",
                                color: .orange
                            )
                            
                            // Сон
                            HealthMetricCard(
                                title: "Сон",
                                value: "\(sleepHours) ч",
                                icon: "moon.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Рекомендации по восстановлению
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Рекомендации по восстановлению")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 10) {
                                ForEach(recoveryTips, id: \.self) { tip in
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        
                                        Text(tip)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Кнопка отметки восстановления
                            Button(action: {
                                recoveryCompleted.toggle()
                            }) {
                                Text(recoveryCompleted ? "Восстановление отмечено" : "Отметить восстановление")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(recoveryCompleted ? Color.gray : Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .disabled(recoveryCompleted)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    
                    // Добавляем отступ снизу для таб-бара
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

// Модель данных для графика
struct WorkoutData: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// Компонент карточки показателя здоровья
struct HealthMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    StatisticsView()
}
