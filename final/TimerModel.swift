import Foundation
import SwiftUI

enum TimerState {
    case stopped
    case running
    case paused
}

enum TimerMode {
    case work
    case rest
}

class BoxingTimer: ObservableObject {
    @Published var secondsRemaining: Int = 180 // 3 минуты по умолчанию
    @Published var timerState: TimerState = .stopped
    @Published var timerMode: TimerMode = .work
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 3
    
    @Published var workDuration: Int = 180 // 3 минуты работы
    @Published var restDuration: Int = 60 // 1 минута отдыха
    
    private var timer: Timer?
    
    func startTimer() {
        timerState = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
            } else {
                // Переключение между режимами работы и отдыха
                if self.timerMode == .work {
                    // Если закончился рабочий период
                    if self.currentRound < self.totalRounds {
                        // Если не последний раунд, переходим к отдыху
                        self.timerMode = .rest
                        self.secondsRemaining = self.restDuration
                    } else {
                        // Если последний раунд, останавливаем таймер
                        self.resetTimer()
                    }
                } else {
                    // Если закончился период отдыха, переходим к следующему раунду
                    self.currentRound += 1
                    self.timerMode = .work
                    self.secondsRemaining = self.workDuration
                }
            }
        }
    }
    
    func pauseTimer() {
        timerState = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        startTimer()
    }
    
    func resetTimer() {
        pauseTimer()
        timerState = .stopped
        timerMode = .work
        secondsRemaining = workDuration
        currentRound = 1
    }
    
    func resetCurrentRound() {
        pauseTimer()
        secondsRemaining = timerMode == .work ? workDuration : restDuration
        timerState = .stopped
    }
    
    func formatTime() -> String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
    }
}
