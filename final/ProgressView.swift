import SwiftUI

struct ProgressView: View {
    @State private var selectedMetric = 0
    let metrics = ["Сила", "Выносливость", "Техника", "Скорость"]
    
    var body: some View {
        VStack {
            Picker("Метрика", selection: $selectedMetric) {
                ForEach(0..<metrics.count, id: \.self) { index in
                    Text(metrics[index])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Sample chart
            Chart(data: sampleData())
                .frame(height: 250)
                .padding()
            
            // Recent achievements
            VStack(alignment: .leading) {
                Text("Последние достижения")
                    .font(.headline)
                    .padding(.horizontal)
                
                List {
                    AchievementRow(title: "5 тренировок подряд", date: "10 апреля")
                    AchievementRow(title: "Улучшение техники джеба на 15%", date: "8 апреля")
                    AchievementRow(title: "Новый рекорд: 50 ударов за минуту", date: "5 апреля")
                }
            }
        }
        .navigationTitle("Прогресс")
    }
    
    func sampleData() -> [Double] {
        switch selectedMetric {
        case 0: return [65, 70, 72, 78, 82, 85]
        case 1: return [50, 55, 60, 65, 68, 72]
        case 2: return [40, 50, 60, 65, 75, 80]
        case 3: return [55, 60, 62, 68, 72, 78]
        default: return [50, 60, 70, 80, 90, 100]
        }
    }
}

struct AchievementRow: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct Chart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data.indices, id: \.self) { index in
                    let height = data[index] / 100 * geometry.size.height
                    
                    VStack {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: (geometry.size.width - CGFloat(data.count) * 4) / CGFloat(data.count), height: height)
                        
                        Text("\(index + 1)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    NavigationView {
        ProgressView()
    }
}
