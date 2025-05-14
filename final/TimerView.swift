import SwiftUI

struct TimerView: View {
    @StateObject private var timerModel = BoxingTimer()
    @State private var showingCustomizationView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var animateRing = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент в зависимости от режима
            LinearGradient(
                gradient: Gradient(colors: [
                    timerModel.timerMode == .work ? Color.red.opacity(0.8) : Color.green.opacity(0.8),
                    timerModel.timerMode == .work ? Color.red.opacity(0.4) : Color.green.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Фоновые круги для дизайна
            Circle()
                .fill(timerModel.timerMode == .work ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(timerModel.timerMode == .work ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 200)
            
            VStack(spacing: 30) {
                // Заголовок с анимированным фоном
                Text(timerModel.timerMode == .work ? "РАУНД \(timerModel.currentRound)/\(timerModel.totalRounds)" : "ОТДЫХ")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 25)
                    .background(
                        Capsule()
                            .fill(timerModel.timerMode == .work ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Таймер с анимированным кольцом
                ZStack {
                    // Фоновое кольцо
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.1)
                        .foregroundColor(.white)
                    
                    // Прогресс кольцо
                    Circle()
                        .trim(from: 0.0, to: 1.0 - (Double(timerModel.secondsRemaining) / Double(timerModel.timerMode == .work ? timerModel.workDuration : timerModel.restDuration)))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.linear(duration: 1.0), value: timerModel.secondsRemaining)
                    
                    VStack(spacing: 5) {
                        // Время
                        Text(timerModel.formatTime())
                            .font(.system(size: 70, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Режим
                        Text(timerModel.timerMode == .work ? "РАБОТА" : "ОТДЫХ")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                
                // Кнопки управления с улучшенным дизайном
                HStack(spacing: 40) {
                    // Кнопка сброса текущего раунда
                    TimerButton(icon: "arrow.counterclockwise", action: {
                        timerModel.resetCurrentRound()
                    })
                    
                    // Кнопка старт/пауза (увеличенная)
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Button(action: {
                            if timerModel.timerState == .running {
                                timerModel.pauseTimer()
                            } else {
                                if timerModel.timerState == .stopped {
                                    timerModel.startTimer()
                                } else {
                                    timerModel.resumeTimer()
                                }
                            }
                        }) {
                            Image(systemName: timerModel.timerState == .running ? "pause.fill" : "play.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Кнопка выхода к настройкам таймера
                    TimerButton(icon: "gear", action: {
                        timerModel.pauseTimer()
                        showingCustomizationView = true
                    })
                }
                
                Spacer()
                
                // Кнопка возврата с улучшенным дизайном
                Button(action: {
                    timerModel.pauseTimer()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                        Text("ВЕРНУТЬСЯ")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .sheet(isPresented: $showingCustomizationView) {
            TimerCustomizationView(timerModel: timerModel)
        }
        .navigationBarHidden(true)
        .onAppear {
            animateRing = true
        }
    }
}

// Компонент кнопки таймера
struct TimerButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct TimerCustomizationView: View {
    @ObservedObject var timerModel: BoxingTimer
    @Environment(\.presentationMode) var presentationMode
    
    @State private var workMinutes: Double
    @State private var workSeconds: Double
    @State private var restMinutes: Double
    @State private var restSeconds: Double
    @State private var rounds: Double
    
    init(timerModel: BoxingTimer) {
        self.timerModel = timerModel
        _workMinutes = State(initialValue: Double(timerModel.workDuration / 60))
        _workSeconds = State(initialValue: Double(timerModel.workDuration % 60))
        _restMinutes = State(initialValue: Double(timerModel.restDuration / 60))
        _restSeconds = State(initialValue: Double(timerModel.restDuration % 60))
        _rounds = State(initialValue: Double(timerModel.totalRounds))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Длительность раунда")) {
                    HStack {
                        Text("Минуты")
                        Slider(value: $workMinutes, in: 0...10, step: 1)
                        Text("\(Int(workMinutes))")
                    }
                    
                    HStack {
                        Text("Секунды")
                        Slider(value: $workSeconds, in: 0...59, step: 5)
                        Text("\(Int(workSeconds))")
                    }
                }
                
                Section(header: Text("Длительность отдыха")) {
                    HStack {
                        Text("Минуты")
                        Slider(value: $restMinutes, in: 0...5, step: 1)
                        Text("\(Int(restMinutes))")
                    }
                    
                    HStack {
                        Text("Секунды")
                        Slider(value: $restSeconds, in: 0...59, step: 5)
                        Text("\(Int(restSeconds))")
                    }
                }
                
                Section(header: Text("Количество раундов")) {
                    HStack {
                        Text("Раунды")
                        Slider(value: $rounds, in: 1...12, step: 1)
                        Text("\(Int(rounds))")
                    }
                }
                
                Section {
                    Button("Применить настройки") {
                        applySettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Настройки таймера")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func applySettings() {
        // Преобразуем минуты и секунды в общее количество секунд
        timerModel.workDuration = Int(workMinutes) * 60 + Int(workSeconds)
        timerModel.restDuration = Int(restMinutes) * 60 + Int(restSeconds)
        timerModel.totalRounds = Int(rounds)
        
        // Если таймер не запущен, обновляем текущее время
        if timerModel.timerState == .stopped {
            if timerModel.timerMode == .work {
                timerModel.secondsRemaining = timerModel.workDuration
            } else {
                timerModel.secondsRemaining = timerModel.restDuration
            }
        }
    }
}

#Preview {
    TimerView()
}
