import SwiftUI

struct MoreOptionsView: View {
    // Сервис данных для работы с API
    @EnvironmentObject private var dataService: DataService
    // Опции дополнительного меню
    let menuOptions = [
        MenuOption(title: "Достижения", icon: "trophy.fill", color: .yellow, destination: AnyView(AchievementsView())),
        MenuOption(title: "Восстановление", icon: "heart.fill", color: .green, destination: AnyView(RecoveryView())),
        MenuOption(title: "Вопросы и ответы", icon: "questionmark.circle.fill", color: .blue, destination: AnyView(FAQView())),
        MenuOption(title: "Таймер", icon: "timer", color: .orange, destination: AnyView(TimerView())),
        MenuOption(title: "Интеграция с Apple Watch", icon: "applewatch", color: .gray, destination: AnyView(AppleWatchIntegrationView()))
    ]
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                Text("Дополнительно")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Список опций
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(menuOptions) { option in
                            NavigationLink(destination: option.destination) {
                                MenuOptionRow(option: option)
                            }
                        }
                        

                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

// Модель опции меню
struct MenuOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

// Компонент строки меню
struct MenuOptionRow: View {
    let option: MenuOption
    
    var body: some View {
        HStack {
            // Иконка
            ZStack {
                Circle()
                    .fill(option.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: option.icon)
                    .font(.system(size: 24))
                    .foregroundColor(option.color)
            }
            
            // Название
            Text(option.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Стрелка
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationView {
        MoreOptionsView()
    }
}
