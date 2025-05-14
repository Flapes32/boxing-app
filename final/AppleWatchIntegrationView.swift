import SwiftUI
import WatchConnectivity
import Combine

// MARK: - WatchConnectivity manager (basic stub)
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    // Состояние соединения
    @Published var isPaired: Bool = false
    @Published var isReachable: Bool = false
    @Published var latestMetrics: WatchMetrics? = WatchMetrics.sample

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        isPaired = session.isPaired
        isReachable = session.isReachable
    }

    // MARK: - WCSessionDelegate (минимум)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let json = message["metrics"] as? String,
           let data = json.data(using: .utf8),
           let metrics = try? JSONDecoder().decode(WatchMetrics.self, from: data) {
            DispatchQueue.main.async {
                self.latestMetrics = metrics
            }
        }
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
#endif
}

struct WatchMetrics: Codable {
    let timestamp: TimeInterval
    let heartRate: Double
    let activeEnergy: Double
    let workoutDuration: Double
    let steps: Int
    let distance: Double // meters
    let rounds: Int
    
    static let sample = WatchMetrics(timestamp: Date().timeIntervalSince1970,
                                     heartRate: 130,
                                     activeEnergy: 350,
                                     workoutDuration: 900,
                                     steps: 2000,
                                     distance: 2400,
                                     rounds: 3)
}

// MARK: - SwiftUI View
struct AppleWatchIntegrationView: View {
    @StateObject private var wcManager = WatchConnectivityManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "figure.boxing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.red)
                    .padding(.top, 10)

                Text("Ринг-статистика")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 10)

                let m = wcManager.latestMetrics ?? WatchMetrics.sample
                // Grid with square widgets
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricsCard(title: "Пульс", value: String(format: "%.0f", m.heartRate), unit: "bpm", systemImage: "heart.fill", colors: [.red, .black])
                    MetricsCard(title: "Раунды", value: "\(m.rounds)", unit: "", systemImage: "circle.fill", colors: [.blue, .indigo])
                    MetricsCard(title: "Калории", value: String(format: "%.0f", m.activeEnergy), unit: "kcal", systemImage: "flame.fill", colors: [.yellow, .orange])
                    MetricsCard(title: "Время", value: String(format: "%.0f", m.workoutDuration/60), unit: "мин", systemImage: "timer", colors: [.teal, .blue])
                    MetricsCard(title: "Дистанция", value: String(format: "%.1f", m.distance/1000), unit: "км", systemImage: "location.fill", colors: [.purple, .black])
                }
                
                // Intensity gauge
                GaugeCard(title: "Интенсивность", value: m.heartRate, max: 200, colors: [.green, .yellow, .red])
            }
            .padding(.horizontal)
        }
        .navigationTitle("Watch Stats")
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

#Preview {
    NavigationView { AppleWatchIntegrationView() }
}
