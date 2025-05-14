import SwiftUI

struct RecoveryView: View {
    // Категории рекомендаций
    @State private var selectedCategory = 0
    let categories = ["Персонализированные тренировки", "Рекомендации по питанию", "Техника выполнения упражнений", "Истории успеха"]
    
    // Рекомендации по тренировкам
    let workoutRecommendations = [
        RecommendationItem(
            title: "Для новичков: тренировки с низкой нагрузкой",
            description: "Начните с 3 тренировок в неделю по 30-40 минут. Фокусируйтесь на правильной технике и постепенно увеличивайте нагрузку.",
            icon: "figure.boxing"
        ),
        RecommendationItem(
            title: "Для опытных: интенсивные тренировки с целевыми результатами",
            description: "5-6 тренировок в неделю с чередованием силовых и кардио нагрузок. Включайте интервальные тренировки для максимальной эффективности.",
            icon: "flame.fill"
        )
    ]
    
    // Рекомендации по питанию
    let nutritionRecommendations = [
        RecommendationItem(
            title: "Продукты для набора мышечной массы",
            description: "Увеличьте потребление белка (курица, рыба, яйца, творог), сложных углеводов (крупы, макароны из твердых сортов пшеницы) и полезных жиров (орехи, авокадо).",
            icon: "fork.knife"
        ),
        RecommendationItem(
            title: "Диета для сжигания жира",
            description: "Создайте небольшой дефицит калорий, увеличьте потребление белка, овощей и воды. Ограничьте простые углеводы и обработанные продукты.",
            icon: "scalemass.fill"
        )
    ]
    
    // Техника выполнения
    let techniqueRecommendations = [
        RecommendationItem(
            title: "Как правильно подседать",
            description: "Держите спину прямой, колени не должны выходить за носки. Опускайтесь до параллели бедер с полом или ниже в зависимости от вашей подвижности.",
            icon: "figure.strengthtraining.traditional"
        ),
        RecommendationItem(
            title: "Как избегать травм при подъеме тяжестей",
            description: "Всегда разминайтесь перед тренировкой. Используйте правильную технику, не округляйте спину при подъеме. Начинайте с легких весов и постепенно увеличивайте нагрузку.",
            icon: "bandage.fill"
        )
    ]
    
    // Истории успеха
    let successStories = [
        RecommendationItem(
            title: "Как Иван похудел на 20 кг за 6 месяцев",
            description: "Иван начал с простых тренировок 3 раза в неделю и постепенно увеличивал интенсивность. Он пересмотрел свой рацион, убрав фастфуд и сладкие напитки. Результат — минус 20 кг и значительное улучшение здоровья.",
            icon: "person.fill.checkmark"
        ),
        RecommendationItem(
            title: "История Марии: от новичка до профессионала",
            description: "Мария начала заниматься боксом для поддержания формы, но через год тренировок обнаружила в себе талант. Сейчас она участвует в региональных соревнованиях и планирует стать профессиональным тренером.",
            icon: "trophy.fill"
        )
    ]
    
    var recommendationsToShow: [RecommendationItem] {
        switch selectedCategory {
        case 0:
            return workoutRecommendations
        case 1:
            return nutritionRecommendations
        case 2:
            return techniqueRecommendations
        case 3:
            return successStories
        default:
            return workoutRecommendations
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый цвет
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    Text("Советы и рекомендации")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Переключатель категорий
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                CategoryButton(
                                    title: categories[index],
                                    isSelected: selectedCategory == index,
                                    action: {
                                        selectedCategory = index
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Заголовок выбранной категории
                    Text(categories[selectedCategory])
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Список рекомендаций
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(recommendationsToShow) { item in
                                RecommendationCard(item: item)
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
}

// Модель рекомендации
struct RecommendationItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

// Компонент кнопки категории
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .yellow : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(
                    isSelected ?
                    Color(.systemGray6).opacity(0.3) :
                    Color.clear
                )
                .cornerRadius(20)
        }
    }
}

// Компонент карточки рекомендации
struct RecommendationCard: View {
    let item: RecommendationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(5)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    RecoveryView()
}
