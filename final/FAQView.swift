import SwiftUI

struct FAQView: View {
    // Категории вопросов
    @State private var selectedCategory = 0
    let categories = ["ОБЩИЕ ВОПРОСЫ", "ПИТАНИЕ И ДИЕТЫ", "ВОССТАНОВЛЕНИЕ И ТРАВМЫ"]
    
    // Общие вопросы
    let generalQuestions = [
        FAQItem(
            question: "Как выбрать тренажер для дома?",
            answer: "При выборе тренажера для дома учитывайте доступное пространство, ваши фитнес-цели и бюджет. Для бокса рекомендуется начать с боксерской груши, перчаток и скакалки. Если позволяет место, рассмотрите вариант с боксерским мешком на стойке."
        ),
        FAQItem(
            question: "Что делать, если я не могу выполнять упражнение правильно?",
            answer: "Начните с более легкой версии упражнения или уменьшите вес. Сосредоточьтесь на правильной технике, а не на количестве повторений. Рассмотрите возможность консультации с тренером для корректировки техники."
        ),
        FAQItem(
            question: "Как не потерять мотивацию?",
            answer: "Ставьте конкретные, измеримые и достижимые цели. Отслеживайте свой прогресс в приложении. Найдите партнера по тренировкам или присоединитесь к группе. Разнообразьте тренировки и вознаграждайте себя за достижения."
        )
    ]
    
    // Вопросы о питании
    let nutritionQuestions = [
        FAQItem(
            question: "Что есть перед тренировкой?",
            answer: "За 1-2 часа до тренировки рекомендуется употребить легкоусвояемые углеводы и немного белка. Например, банан с йогуртом, овсянка с фруктами или тост с яйцом. Избегайте тяжелой, жирной пищи перед тренировкой."
        ),
        FAQItem(
            question: "Какие продукты лучше для роста мышц?",
            answer: "Для роста мышц важен достаточный прием белка (1.6-2.2 г на кг веса). Лучшие источники: куриная грудка, яйца, творог, рыба, говядина, греческий йогурт. Также важны сложные углеводы (рис, киноа, овсянка) и полезные жиры (орехи, авокадо)."
        ),
        FAQItem(
            question: "Какая диета лучше при снижении веса?",
            answer: "Эффективное снижение веса требует небольшого дефицита калорий (300-500 ккал в день). Увеличьте потребление белка (помогает сохранить мышцы), овощей и воды. Ограничьте простые углеводы и обработанные продукты. Важно: диета должна быть устойчивой в долгосрочной перспективе."
        )
    ]
    
    // Вопросы о восстановлении
    let recoveryQuestions = [
        FAQItem(
            question: "Как избежать травм при тренировках?",
            answer: "Всегда начинайте с разминки (5-10 минут). Используйте правильную технику и подходящий вес. Увеличивайте нагрузку постепенно. Слушайте свое тело и не игнорируйте боль. Включайте в программу дни отдыха и восстановления. Используйте подходящую обувь и экипировку."
        ),
        FAQItem(
            question: "Как восстановиться после интенсивной тренировки?",
            answer: "После интенсивной тренировки важно: 1) Восполнить жидкость и электролиты; 2) Употребить белок и углеводы в течение 30-60 минут; 3) Обеспечить достаточный сон (7-9 часов); 4) Использовать активное восстановление (легкая активность); 5) При необходимости применять холод или тепло для снятия воспаления."
        ),
        FAQItem(
            question: "Как правильно растягиваться после тренировки?",
            answer: "Растяжка после тренировки должна быть статической (удержание позиции 20-30 секунд). Растягивайте все основные группы мышц, особенно те, которые были задействованы. Дышите глубоко и равномерно. Не растягивайтесь до сильной боли, только до ощущения легкого дискомфорта."
        )
    ]
    
    var questionsToShow: [FAQItem] {
        switch selectedCategory {
        case 0:
            return generalQuestions
        case 1:
            return nutritionQuestions
        case 2:
            return recoveryQuestions
        default:
            return generalQuestions
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый цвет
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    Text("FAQ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Переключатель категорий
                    HStack(spacing: 0) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Button(action: {
                                selectedCategory = index
                            }) {
                                Text(categories[index])
                                    .font(.caption)
                                    .fontWeight(selectedCategory == index ? .bold : .regular)
                                    .foregroundColor(selectedCategory == index ? .white : .gray)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                            }
                            .background(
                                selectedCategory == index ?
                                Color(.systemGray6).opacity(0.3) :
                                Color.clear
                            )
                        }
                    }
                    .background(Color(.systemGray6).opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // Список вопросов и ответов
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(questionsToShow) { item in
                                FAQItemView(item: item)
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

// Модель вопроса и ответа
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    @State var isExpanded: Bool = false
}

// Компонент вопроса и ответа
struct FAQItemView: View {
    @State var item: FAQItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Вопрос с кнопкой раскрытия
            Button(action: {
                withAnimation {
                    item.isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: item.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            // Ответ (отображается при раскрытии)
            if item.isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    FAQView()
}
