import SwiftUI

struct ProfileView: View {
    @State private var userName = "Александр"
    @State private var userLevel = "Средний"
    @State private var trainingDays = 45
    @State private var weight = "75 кг"
    @State private var height = "180 см"
    @State private var isEditingProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.yellow)
                    
                    Text(userName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Уровень: \(userLevel)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("\(trainingDays) дней тренировок")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .padding()
                
                // Stats section
                VStack(alignment: .leading) {
                    Text("Физические данные")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        StatCard(title: "Вес", value: weight, icon: "scalemass.fill")
                        StatCard(title: "Рост", value: height, icon: "ruler.fill")
                    }
                    .padding(.horizontal)
                }
                
                // Achievements section
                VStack(alignment: .leading) {
                    Text("Достижения")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            AchievementCard(title: "Первая тренировка", icon: "star.fill", color: .yellow)
                            AchievementCard(title: "10 дней подряд", icon: "flame.fill", color: .orange)
                            AchievementCard(title: "Мастер джеба", icon: "hand.raised.fill", color: .green)
                            AchievementCard(title: "Выносливость +10", icon: "heart.fill", color: .red)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                // Settings buttons
                VStack {
                    Button(action: { isEditingProfile.toggle() }) {
                        SettingsRow(icon: "person.fill", title: "Редактировать профиль")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        SettingsRow(icon: "bell.fill", title: "Уведомления")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        SettingsRow(icon: "gear", title: "Настройки")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        SettingsRow(icon: "questionmark.circle", title: "Помощь")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Профиль")
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(
                userName: $userName,
                weight: $weight,
                height: $height
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .padding()
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userName: String
    @Binding var weight: String
    @Binding var height: String
    
    @State private var tempUserName: String = ""
    @State private var tempWeight: String = ""
    @State private var tempHeight: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Личные данные")) {
                    TextField("Имя", text: $tempUserName)
                    TextField("Вес (кг)", text: $tempWeight)
                    TextField("Рост (см)", text: $tempHeight)
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    userName = tempUserName
                    weight = tempWeight
                    height = tempHeight
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                tempUserName = userName
                tempWeight = weight
                tempHeight = height
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
