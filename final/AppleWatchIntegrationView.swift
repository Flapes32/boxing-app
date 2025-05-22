import SwiftUI
import WatchConnectivity
import Combine
import Charts

// MARK: - SwiftUI View
struct AppleWatchIntegrationView: View {
        @StateObject private var wcManager = WatchConnectivityManager.shared
    @State private var selectedTimeFrame: TimeFrame = .day
    @State private var showConnectionInfo = false
    @State private var showSyncSheet = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Заголовок и статус подключения
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Apple Watch")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // В демо-режиме просто показываем информацию
                        showConnectionInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                // Иконка Apple Watch с кружком
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "applewatch")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
                
                Text("Статистика Apple Watch")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Статус подключения
                HStack {
                    Image(systemName: wcManager.isReachable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(wcManager.isReachable ? .green : .red)
                    
                    Text(wcManager.isReachable ? "Часы подключены" : "Часы не подключены")
                        .foregroundColor(wcManager.isReachable ? .green : .red)
                }
                .padding(.bottom, 10)
                
                Text("СТАТИСТИКА ТРЕНИРОВКИ")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Показатели тренировки в сетке
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCardView(
                        icon: "heart.fill",
                        value: "130",
                        unit: "bpm",
                        title: "Пульс",
                        color: .red
                    )
                    
                    MetricCardView(
                        icon: "circle.grid.3x3.fill",
                        value: "3",
                        unit: "",
                        title: "Раунды",
                        color: .yellow
                    )
                    
                    MetricCardView(
                        icon: "flame.fill",
                        value: "350",
                        unit: "kcal",
                        title: "Калории",
                        color: .orange
                    )
                    
                    MetricCardView(
                        icon: "clock.fill",
                        value: "15",
                        unit: "мин",
                        title: "Время",
                        color: .blue
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Нижняя панель навигации
                
            
            }
        }
        .alert("Статус подключения", isPresented: $showConnectionInfo) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("Часы сопряжены: \(wcManager.isPaired ? "Да" : "Нет")\nЧасы доступны: \(wcManager.isReachable ? "Да" : "Нет")\nПриложение установлено: \(wcManager.isWatchAppInstalled ? "Да" : "Нет")")
        }
        .onAppear {
            // Безопасная инициализация с задержкой для iOS 18.4.1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak wcManager] in
                guard let wcManager = wcManager else { return }
                
                // Проверка доступности часов
                wcManager.checkWatchAvailability()
                
                // Запрос данных только если часы доступны
                if wcManager.isReachable {
                    wcManager.requestWorkoutData()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Компоненты интерфейса
    
    // Компонент для отображения метрики в стиле скриншота
    struct MetricCardView: View {
        let icon: String
        let value: String
        let unit: String
        let title: String
        let color: Color
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: 2)
                    )
                
                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(color)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        if !unit.isEmpty {
                            Text(unit)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .frame(height: 120)
        }
    }
    
    // Компонент для кнопки нижней панели навигации
    struct TabBarButton: View {
        let icon: String
        let text: String
        let isSelected: Bool
        
        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .yellow : .gray)
                
                Text(text)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .yellow : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    // Переключатель временного интервала
    private var timeFrameSelector: some View {
        HStack {
            Text("Графики")
                .font(.headline)
            
            Spacer()
            
            TabBarButton(icon: "ellipsis", text: "Еще", isSelected: true)
            
            Picker("", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
        .padding(.horizontal)
    }
    
    // График пульса
    private var heartRateChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Пульс")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if wcManager.workoutDataHistory.isEmpty {
                noDataView
            } else {
                // Вместо графика используем список данных
                VStack(alignment: .leading) {
                    Text("Последние данные о пульсе:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wcManager.workoutDataHistory.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5), id: \.timestamp) { data in
                                HStack {
                                    Text(Date(timeIntervalSince1970: data.timestamp), style: .time)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("Пульс: \(Int(data.heartRate)) уд/мин")
                                        .font(.body)
                                        .foregroundColor(.red)
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    // График калорий
    private var caloriesChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Калории")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if wcManager.workoutDataHistory.isEmpty {
                noDataView
            } else {
                // Вместо графика используем список данных
                VStack(alignment: .leading) {
                    Text("Последние данные о калориях:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(wcManager.workoutDataHistory.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5), id: \.timestamp) { data in
                                HStack {
                                    Text(Date(timeIntervalSince1970: data.timestamp), style: .time)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("Калории: \(Int(data.activeEnergy)) ккал")
                                        .font(.body)
                                        .foregroundColor(.orange)
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    // Экран синхронизации
    private var syncOptionsView: some View {
        NavigationView {
            List {
                Section(header: Text("Синхронизация данных")) {
                    Button(action: {
                        wcManager.requestWorkoutData()
                        showSyncSheet = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("Запросить данные с часов")
                        }
                    }
                    
                    Button(action: {
                        // Получаем настройки таймера из BoxingTimer
                        let timerModel = BoxingTimer()
                        let settings = TimerSettings(
                            workDuration: timerModel.workDuration,
                            restDuration: timerModel.restDuration,
                            rounds: timerModel.totalRounds,
                            exercises: []
                        )
                        wcManager.sendTimerSettings(settings: settings)
                        showSyncSheet = false
                    }) {
                        HStack {
                            Image(systemName: "timer")
                            Text("Отправить настройки таймера")
                        }
                    }
                }
                
                Section(header: Text("Управление тренировкой")) {
                    Button(action: {
                        wcManager.startWorkout()
                        showSyncSheet = false
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Начать тренировку")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        wcManager.stopWorkout()
                        showSyncSheet = false
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Завершить тренировку")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Синхронизация")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        showSyncSheet = false
                    }
                }
            }
        }
    }
    
    // Заглушка при отсутствии данных
    private var noDataView: some View {
        VStack {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Text("Нет данных для отображения")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct MetricsCard: View {
    let title: String
    let value: String
    var unit: String = ""
    let systemImage: String
    let colors: [Color]
    
    var body: some View {
        ZStack {
            let gradient = LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Text(value)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct GaugeCard: View {
    let title: String
    let value: Double
    let max: Double
    let colors: [Color]
    
    var body: some View {
        let gradient = Gradient(colors: colors)
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Gauge(value: value, in: 0...max) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(Int(value)) bpm")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
            }
            .padding()
        }
        .frame(height: 90)
    }
}

// Временные интервалы для графиков
enum TimeFrame: String, CaseIterable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
}

#Preview {
    NavigationView { AppleWatchIntegrationView() }
}


