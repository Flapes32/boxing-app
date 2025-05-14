import Foundation

enum WorkoutDifficulty: String, Codable, CaseIterable {
    case beginner = "Начинающий"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
    case professional = "Профессионал"
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case warmup = "Разминка"
    case technique = "Техника"
    case strength = "Силовые"
    case cardio = "Кардио"
    case cooldown = "Заминка"
    case stretching = "Растяжка"
    case combinations = "Комбинации"
    
    var icon: String {
        switch self {
        case .warmup: return "flame.fill"
        case .technique: return "figure.boxing"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .cooldown: return "wind"
        case .stretching: return "figure.flexibility"
        case .combinations: return "figure.boxing.motion"
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case arms = "Руки"
    case shoulders = "Плечи"
    case chest = "Грудь"
    case back = "Спина"
    case core = "Кор"
    case legs = "Ноги"
    case fullBody = "Все тело"
}

struct Exercise: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let instructions: String
    let category: ExerciseCategory
    let difficulty: WorkoutDifficulty
    let targetMuscles: [MuscleGroup]
    let duration: Int? // в секундах
    let repetitions: Int?
    let sets: Int?
    let restBetweenSets: Int? // в секундах
    let videoURL: String?
    let tips: [String]
    let commonMistakes: [String]
    let equipment: [String]
    
    // Вычисляемое свойство для отображения формата упражнения
    var format: String {
        if let repetitions = repetitions, let sets = sets {
            return "\(sets) × \(repetitions)"
        } else if let duration = duration {
            let minutes = duration / 60
            let seconds = duration % 60
            if minutes > 0 {
                return "\(minutes) мин \(seconds) сек"
            } else {
                return "\(seconds) сек"
            }
        } else {
            return "Произвольно"
        }
    }
}

// База данных упражнений
struct ExerciseDatabase {
    static let exercises: [Exercise] = [
        // Разминка
        Exercise(
            id: "warmup-1",
            name: "Техника",
            description: "Основные техники бокса",
            instructions: "Примите боевую стойку",
            category: .warmup,
            difficulty: .beginner,
            targetMuscles: [.legs, .core],
            duration: 10,
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=FJmRQ5iTXKE",
            tips: ["Начните с базовых прыжков"],
            commonMistakes: ["Слишком высокие прыжки"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // Техника
        Exercise(
            id: "technique-1",
            name: "Техника",
            description: "Основные техники бокса",
            instructions: "Примите боевую стойку",
            category: .technique,
            difficulty: .beginner,
            targetMuscles: [.arms, .shoulders],
            duration: 10,
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=1D9v6KtBQrk",
            tips: ["Держите вторую руку у подбородка", "Разворачивайте кулак в конце удара"],
            commonMistakes: ["Опущенная вторая рука"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        Exercise(
            id: "technique-2",
            name: "Кросс",
            description: "Боксерская техника кросса",
            instructions: "Из боевой стойки",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders],
            duration: 15,
            repetitions: 8,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=2Xo3NJ7LCCw",
            tips: ["Используйте вращение бедер", "Держите защиту"],
            commonMistakes: ["Нет вращения корпуса"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // Комбинации
        Exercise(
            id: "combinations-1",
            name: "Джеб",
            description: "Боксерская техника джеба",
            instructions: "Джеб передней рукой",
            category: .combinations,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders],
            duration: 20,
            repetitions: 5,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=7v0_uipNGao",
            tips: ["Начинайте медленно", "Следите за точностью"],
            commonMistakes: ["Остановка между ударами"],
            equipment: ["Боксерские перчатки", "Бинты", "Груша"]
        ),
        Exercise(
            id: "technique-3",
            name: "Бой с тенью",
            description: "Постоянное движение",
            instructions: "Постоянное движение",
            category: .technique,
            difficulty: .advanced,
            targetMuscles: [.fullBody],
            duration: 45,
            repetitions: 2,
            sets: 2,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=kqB19LuJ5jE",
            tips: ["Представляйте реального противника", "Работайте в разных темпах"],
            commonMistakes: ["Отсутствие защитных действий"],
            equipment: ["Боксерские перчатки (опционально)"]
        ),
        // 6. Апперкот
        Exercise(
            id: "technique-6",
            name: "Апперкот",
            description: "Удар снизу вверх",
            instructions: "Выполните удар снизу вверх с небольшим сгибанием в коленях и выпрямлением при ударе.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders, .core],
            repetitions: 10,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=7JYKYTgrppU",
            tips: ["Используйте силу ног", "Поворачивайте корпус"],
            commonMistakes: ["Слишком широкий замах", "Отсутствие работы ног"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // 7. Двойка (джеб + кросс)
        Exercise(
            id: "combinations-1",
            name: "Двойка",
            description: "Базовая комбинация джеб + кросс",
            instructions: "Выполните прямой удар передней рукой, затем сразу прямой удар задней рукой.",
            category: .combinations,
            difficulty: .beginner,
            targetMuscles: [.arms, .shoulders, .core],
            repetitions: 15,
            sets: 4,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=q1NZZnQFfRk",
            tips: ["Сохраняйте равновесие", "Возвращайте руки в защитную позицию"],
            commonMistakes: ["Опускание рук", "Потеря равновесия"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // 8. Тройка (джеб + кросс + хук)
        Exercise(
            id: "combinations-2",
            name: "Тройка",
            description: "Комбинация джеб + кросс + хук",
            instructions: "Выполните прямой удар передней рукой, затем прямой удар задней рукой, затем боковой удар передней рукой.",
            category: .combinations,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders, .core],
            repetitions: 12,
            sets: 3,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=nJF4LhSNVxg",
            tips: ["Сохраняйте темп", "Поворачивайте корпус при хуке"],
            commonMistakes: ["Потеря равновесия", "Опускание защиты"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // 9. Работа на мешке
        Exercise(
            id: "technique-7",
            name: "Работа на мешке",
            description: "Отработка ударов на тяжелом мешке",
            instructions: "Выполняйте различные комбинации ударов по тяжелому мешку.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders, .core, .legs],
            duration: 180,
            sets: 5,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=91VIWoD4kXg",
            tips: ["Работайте в разных темпах", "Двигайтесь вокруг мешка"],
            commonMistakes: ["Неправильная дистанция", "Отсутствие защитных действий"],
            equipment: ["Боксерские перчатки", "Бинты", "Тяжелый мешок"]
        ),
        // 10. Прыжки на скакалке с двойным оборотом
        Exercise(
            id: "cardio-2",
            name: "Двойные прыжки на скакалке",
            description: "Прыжки на скакалке с двойным оборотом",
            instructions: "Выполняйте прыжки на скакалке, делая два оборота скакалки за один прыжок.",
            category: .cardio,
            difficulty: .advanced,
            targetMuscles: [.legs, .core, .fullBody],
            duration: 180,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=hCuXYrTOMxI",
            tips: ["Прыгайте выше", "Сохраняйте ритм"],
            commonMistakes: ["Недостаточная высота прыжка", "Потеря ритма"],
            equipment: ["Скакалка"]
        ),
        // 11. Берпи
        Exercise(
            id: "cardio-3",
            name: "Берпи",
            description: "Комплексное упражнение для всего тела",
            instructions: "Из положения стоя опуститесь в упор лежа, выполните отжимание, вернитесь в положение стоя и выполните прыжок вверх.",
            category: .cardio,
            difficulty: .intermediate,
            targetMuscles: [.fullBody],
            repetitions: 10,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=TU8QYVW0gDU",
            tips: ["Сохраняйте темп", "Полностью выпрямляйтесь в прыжке"],
            commonMistakes: ["Неполное выполнение отжимания", "Сутулость спины"],
            equipment: []
        ),
        // 12. Отжимания с хлопком
        Exercise(
            id: "strength-1",
            name: "Отжимания с хлопком",
            description: "Взрывные отжимания для развития силы и скорости",
            instructions: "Выполните отжимание с таким усилием, чтобы оторвать руки от пола и успеть сделать хлопок перед грудью.",
            category: .strength,
            difficulty: .advanced,
            targetMuscles: [.chest, .arms, .shoulders],
            repetitions: 8,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=EYwWCgM198U",
            tips: ["Держите корпус напряженным", "Приземляйтесь мягко"],
            commonMistakes: ["Недостаточная высота отрыва", "Прогиб в пояснице"],
            equipment: []
        ),
        // 13. Планка с переходом в боковую планку
        Exercise(
            id: "strength-2",
            name: "Планка с ротацией",
            description: "Укрепление кора с ротационным движением",
            instructions: "Из положения планки на прямых руках поверните корпус и поднимите одну руку вверх, перейдя в боковую планку.",
            category: .strength,
            difficulty: .intermediate,
            targetMuscles: [.core, .shoulders, .arms],
            repetitions: 10,
            sets: 3,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=wqzrb67Dwf8",
            tips: ["Держите корпус стабильным", "Полностью выпрямляйте руку"],
            commonMistakes: ["Прогиб в пояснице", "Недостаточный поворот"],
            equipment: []
        ),
        // 14. Спринт на месте с высоким подниманием колен
        Exercise(
            id: "cardio-4",
            name: "Спринт на месте",
            description: "Интенсивное кардио упражнение",
            instructions: "Бегите на месте с максимальной скоростью, высоко поднимая колени.",
            category: .cardio,
            difficulty: .intermediate,
            targetMuscles: [.legs, .core],
            duration: 30,
            sets: 5,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=ZZZoCNMU48U",
            tips: ["Поднимайте колени до уровня пояса", "Работайте руками как при беге"],
            commonMistakes: ["Недостаточная высота колен", "Слишком медленный темп"],
            equipment: []
        ),
        // 15. Уклоны с гантелями
        Exercise(
            id: "technique-8",
            name: "Уклоны с гантелями",
            description: "Отработка уклонов с дополнительным весом",
            instructions: "Держа гантели у подбородка, выполняйте уклоны вправо и влево.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.core, .shoulders],
            repetitions: 20,
            sets: 3,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=BD_oBmiJbGo",
            tips: ["Сохраняйте боевую стойку", "Не опускайте руки"],
            commonMistakes: ["Слишком широкие уклоны", "Опускание защиты"],
            equipment: ["Гантели"]
        ),
        // 16. Слип (уклон с шагом)
        Exercise(
            id: "technique-9",
            name: "Слип",
            description: "Уклон с шагом в сторону",
            instructions: "Из боевой стойки сделайте небольшой шаг в сторону с одновременным уклоном корпуса.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.legs, .core],
            repetitions: 15,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=vLwRIBxwZuE",
            tips: ["Сохраняйте равновесие", "Держите руки в защитной позиции"],
            commonMistakes: ["Слишком большой шаг", "Опускание рук"],
            equipment: []
        ),
        // 17. Четверка (джеб + кросс + хук + апперкот)
        Exercise(
            id: "combinations-3",
            name: "Четверка",
            description: "Комбинация из четырех ударов",
            instructions: "Выполните последовательно: джеб, кросс, хук и апперкот.",
            category: .combinations,
            difficulty: .advanced,
            targetMuscles: [.arms, .shoulders, .core],
            repetitions: 10,
            sets: 4,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=YnTkqK3t1Bw",
            tips: ["Сохраняйте ритм", "Не забывайте о защите"],
            commonMistakes: ["Потеря равновесия", "Замедление в конце комбинации"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // 18. Удары по лапам
        Exercise(
            id: "technique-10",
            name: "Удары по лапам",
            description: "Отработка точности и силы ударов",
            instructions: "Выполняйте удары по тренировочным лапам, следуя указаниям партнера.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders, .core],
            duration: 180,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=ZHxCUaALbVw",
            tips: ["Фокусируйтесь на точности", "Полностью выпрямляйте руку при прямых ударах"],
            commonMistakes: ["Неправильная дистанция", "Недостаточный поворот корпуса"],
            equipment: ["Боксерские перчатки", "Бинты", "Тренировочные лапы"]
        ),
        // 19. Прыжки из стороны в сторону
        Exercise(
            id: "warmup-2",
            name: "Боковые прыжки",
            description: "Разминка для ног и развитие координации",
            instructions: "Поставьте ноги на ширине плеч и выполняйте прыжки из стороны в сторону.",
            category: .warmup,
            difficulty: .beginner,
            targetMuscles: [.legs, .core],
            duration: 60,
            sets: 3,
            restBetweenSets: 30,
            videoURL: "https://www.youtube.com/watch?v=5VzJdft1nME",
            tips: ["Приземляйтесь мягко на носки", "Держите корпус напряженным"],
            commonMistakes: ["Слишком жесткое приземление", "Недостаточная амплитуда"],
            equipment: []
        ),
        // 20. Скручивания с ударом
        Exercise(
            id: "strength-3",
            name: "Скручивания с ударом",
            description: "Укрепление пресса с имитацией ударов",
            instructions: "Лежа на спине, поднимите корпус и выполните удар рукой вперед.",
            category: .strength,
            difficulty: .intermediate,
            targetMuscles: [.core, .arms],
            repetitions: 15,
            sets: 3,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=pYcEHJvNbJE",
            tips: ["Выдыхайте при подъеме", "Полностью выпрямляйте руку"],
            commonMistakes: ["Рывки при подъеме", "Недостаточное скручивание"],
            equipment: []
        ),
        // 21. Бой с тенью с гантелями
        Exercise(
            id: "technique-11",
            name: "Бой с тенью с гантелями",
            description: "Имитация боя с дополнительным весом",
            instructions: "Держа в руках легкие гантели, выполняйте различные удары и комбинации.",
            category: .technique,
            difficulty: .advanced,
            targetMuscles: [.arms, .shoulders, .core],
            duration: 120,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=xQAV3cHJfQI",
            tips: ["Используйте легкие гантели (0.5-1 кг)", "Сохраняйте правильную технику"],
            commonMistakes: ["Слишком тяжелые гантели", "Нарушение техники"],
            equipment: ["Легкие гантели"]
        ),
        // 22. Растяжка плечевого пояса
        Exercise(
            id: "stretching-1",
            name: "Растяжка плеч",
            description: "Растяжка мышц плечевого пояса",
            instructions: "Вытяните одну руку перед собой и другой рукой прижмите ее к груди. Задержитесь на 20-30 секунд и поменяйте руки.",
            category: .stretching,
            difficulty: .beginner,
            targetMuscles: [.shoulders, .arms],
            duration: 60,
            sets: 2,
            restBetweenSets: 15,
            videoURL: "https://www.youtube.com/watch?v=bP0X3zzL6Xc",
            tips: ["Дышите глубоко", "Не делайте резких движений"],
            commonMistakes: ["Задержка дыхания", "Слишком сильное давление"],
            equipment: []
        ),
        // 23. Прыжки на скакалке с перекрестом
        Exercise(
            id: "cardio-5",
            name: "Прыжки с перекрестом",
            description: "Прыжки на скакалке с перекрещиванием рук",
            instructions: "Во время прыжка на скакалке перекрестите руки перед собой и вернитесь в исходное положение.",
            category: .cardio,
            difficulty: .intermediate,
            targetMuscles: [.legs, .core, .arms],
            duration: 120,
            sets: 3,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=wVtQON4TmEE",
            tips: ["Начните с медленного темпа", "Постепенно увеличивайте скорость"],
            commonMistakes: ["Слишком быстрый темп в начале", "Потеря ритма"],
            equipment: ["Скакалка"]
        ),
        // 24. Комбинация с уклонами
        Exercise(
            id: "combinations-4",
            name: "Комбинация с уклонами",
            description: "Комбинация ударов с защитными действиями",
            instructions: "Выполните джеб, кросс, уклон, хук, уклон.",
            category: .combinations,
            difficulty: .advanced,
            targetMuscles: [.arms, .shoulders, .core, .legs],
            repetitions: 8,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=lLLnJOTuIEE",
            tips: ["Сохраняйте плавность движений", "Не забывайте о защите"],
            commonMistakes: ["Пауза между элементами", "Недостаточная глубина уклонов"],
            equipment: ["Боксерские перчатки", "Бинты"]
        ),
        // 25. Челночный бег с ударами
        Exercise(
            id: "cardio-6",
            name: "Челночный бег с ударами",
            description: "Сочетание бега и ударов",
            instructions: "Разместите два конуса на расстоянии 5-10 метров. Бегите от одного к другому, выполняя на каждом повороте комбинацию из 2-3 ударов.",
            category: .cardio,
            difficulty: .advanced,
            targetMuscles: [.legs, .core, .arms, .fullBody],
            duration: 180,
            sets: 3,
            restBetweenSets: 90,
            videoURL: "https://www.youtube.com/watch?v=FJmRQ5iTXKE",
            tips: ["Сохраняйте правильную технику ударов", "Делайте быстрые повороты"],
            commonMistakes: ["Потеря техники при усталости", "Слишком медленные повороты"],
            equipment: ["Конусы", "Боксерские перчатки (опционально)"]
        ),
        // 26. Растяжка трицепса
        Exercise(
            id: "stretching-2",
            name: "Растяжка трицепса",
            description: "Растяжка трехглавой мышцы плеча",
            instructions: "Поднимите одну руку вверх, согните ее в локте за головой. Другой рукой аккуратно надавите на локоть. Задержитесь на 20-30 секунд и поменяйте руки.",
            category: .stretching,
            difficulty: .beginner,
            targetMuscles: [.arms],
            duration: 60,
            sets: 2,
            restBetweenSets: 15,
            videoURL: "https://www.youtube.com/watch?v=L9IGOcrdcFk",
            tips: ["Держите спину прямо", "Дышите равномерно"],
            commonMistakes: ["Наклон корпуса", "Слишком сильное давление"],
            equipment: []
        ),
        // 27. Удары по груше с перемещением
        Exercise(
            id: "technique-12",
            name: "Удары с перемещением",
            description: "Отработка ударов с перемещением вокруг груши",
            instructions: "Выполняйте серии ударов по груше, постоянно перемещаясь вокруг нее.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders, .legs, .core],
            duration: 180,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=LYj3_Ja1iVQ",
            tips: ["Держите дистанцию", "Работайте на разных уровнях"],
            commonMistakes: ["Постоянная дистанция", "Отсутствие работы ног"],
            equipment: ["Боксерские перчатки", "Бинты", "Груша"]
        ),
        // 28. Выпрыгивания из приседа
        Exercise(
            id: "strength-4",
            name: "Выпрыгивания",
            description: "Развитие взрывной силы ног",
            instructions: "Из положения приседа выполните мощный прыжок вверх, полностью выпрямляя тело в воздухе.",
            category: .strength,
            difficulty: .intermediate,
            targetMuscles: [.legs, .core],
            repetitions: 12,
            sets: 3,
            restBetweenSets: 60,
            videoURL: "https://www.youtube.com/watch?v=72BSr9Etddk",
            tips: ["Приземляйтесь мягко на носки", "Используйте руки для баланса"],
            commonMistakes: ["Неполный присед", "Жесткое приземление"],
            equipment: []
        ),
        // 29. Заминка с растяжкой
        Exercise(
            id: "cooldown-1",
            name: "Комплексная заминка",
            description: "Комплекс упражнений для восстановления после тренировки",
            instructions: "Выполните серию легких растяжек для основных групп мышц, задействованных в тренировке.",
            category: .cooldown,
            difficulty: .beginner,
            targetMuscles: [.fullBody],
            duration: 300,
            sets: 1,
            videoURL: "https://www.youtube.com/watch?v=9a8pFX9zBDw",
            tips: ["Дышите глубоко", "Выполняйте движения медленно"],
            commonMistakes: ["Пропуск заминки", "Слишком интенсивные движения"],
            equipment: []
        ),
        // 30. Удары по воздушной подушке
        Exercise(
            id: "technique-13",
            name: "Удары по подушке",
            description: "Отработка точности и скорости ударов",
            instructions: "Выполняйте серии быстрых ударов по воздушной подушке, закрепленной на стене.",
            category: .technique,
            difficulty: .intermediate,
            targetMuscles: [.arms, .shoulders],
            duration: 120,
            sets: 4,
            restBetweenSets: 45,
            videoURL: "https://www.youtube.com/watch?v=FJmRQ5iTXKE",
            tips: ["Фокусируйтесь на скорости", "Сохраняйте правильную технику"],
            commonMistakes: ["Потеря точности при увеличении скорости", "Опускание рук"],
            equipment: ["Боксерские перчатки", "Бинты", "Воздушная подушка"]
        )
    ]
}
