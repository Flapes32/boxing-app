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
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок и статус подключения
                HStack {
                    Image(systemName: "figure.boxing")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.red)
                    
                    VStack(alignment: .leading) {
                        Text("Ринг-статистика")
                            .font(.title).bold()
                        
                        HStack {
                            Circle()
                                .fill(wcManager.isReachable ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            
                            Text(wcManager.isReachable ? "Apple Watch подключены" : "Apple Watch не подключены")
                                .font(.caption)
                                .foregroundColor(wcManager.isReachable ? .green : .red)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        wcManager.checkWatchAvailability()
                        showConnectionInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                    }
                    .alert("Статус подключения", isPresented: $showConnectionInfo) {
                        Button("ОК", role: .cancel) { }
                    } message: {
                        Text("Часы сопряжены: \(wcManager.isPaired ? "Да" : "Нет")\nЧасы доступны: \(wcManager.isReachable ? "Да" : "Нет")\nПриложение установлено: \(wcManager.isWatchAppInstalled ? "Да" : "Нет")")
                    }
                }
                .padding(.horizontal)
                
                // Кнопки управления тренировкой
                workoutControlsView
                
                // Текущие показатели
                currentMetricsView
                
                // Переключатель временного интервала для графиков
                timeFrameSelector
                
                // График пульса
                heartRateChartView
                
                // График калорий
                caloriesChartView
            }
            .padding(.vertical)
        }
        .navigationTitle("Apple Watch")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSyncSheet = true
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .disabled(!wcManager.isReachable)
            }
        }
        .sheet(isPresented: $showSyncSheet) {
            syncOptionsView
        }
        .onAppear {
            wcManager.checkWatchAvailability()
            wcManager.requestWorkoutData()
        }
    }
    
    // MARK: - Компоненты интерфейса
    
    // Кнопки управления тренировкой
    private var workoutControlsView: some View {
        HStack(spacing: 20) {
            Button(action: {
                if wcManager.isWorkoutInProgress {
                    wcManager.stopWorkout()
                } else {
                    wcManager.startWorkout()
                }
            }) {
                HStack {
                    Image(systemName: wcManager.isWorkoutInProgress ? "stop.fill" : "play.fill")
                    Text(wcManager.isWorkoutInProgress ? "Завершить" : "Начать тренировку")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(wcManager.isWorkoutInProgress ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!wcManager.isReachable)
            
            if wcManager.isWorkoutInProgress {
                Button(action: {
                    wcManager.pauseWorkout()
                }) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("Пауза")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!wcManager.isReachable)
            }
        }
        .padding(.horizontal)
    }
    
    // Текущие показатели тренировки
    private var currentMetricsView: some View {
        let data = wcManager.latestWorkoutData ?? WatchWorkoutData.sample
        
        return VStack(spacing: 15) {
            Text("Текущие показатели")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MetricsCard(title: "Пульс", value: String(format: "%.0f", data.heartRate), unit: "bpm", systemImage: "heart.fill", colors: [.red, .black])
                MetricsCard(title: "Раунды", value: "\(data.rounds)", unit: "", systemImage: "circle.fill", colors: [.blue, .indigo])
                MetricsCard(title: "Калории", value: String(format: "%.0f", data.activeEnergy), unit: "kcal", systemImage: "flame.fill", colors: [.yellow, .orange])
                MetricsCard(title: "Время", value: String(format: "%.0f", data.workoutDuration/60), unit: "мин", systemImage: "timer", colors: [.teal, .blue])
                MetricsCard(title: "Дистанция", value: String(format: "%.1f", data.distance/1000), unit: "км", systemImage: "location.fill", colors: [.purple, .black])
                MetricsCard(title: "Макс. пульс", value: String(format: "%.0f", data.maxHeartRate), unit: "bpm", systemImage: "waveform.path.ecg", colors: [.pink, .red])
            }
            .padding(.horizontal)
            
            // Интенсивность тренировки
            GaugeCard(title: "Интенсивность", value: data.heartRate, max: 200, colors: [.green, .yellow, .red])
                .padding(.horizontal)
        }
    }
    
    // Переключатель временного интервала
    private var timeFrameSelector: some View {
        HStack {
            Text("Графики")
                .font(.headline)
            
            Spacer()
            
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
