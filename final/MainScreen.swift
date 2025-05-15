import SwiftUI

struct MainScreen: View {
    // Временно убираем зависимость от DataService
    // @EnvironmentObject private var dataService: DataService
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(0)
            
            // Workout tab
            NavigationView {
                WorkoutView()
            }
            .tabItem {
                Label("Тренировки", systemImage: "dumbbell")
            }
            .tag(1)
            
            // Social Chat tab
            NavigationView {
                SocialChatView()
            }
            .tabItem {
                Label("Чат", systemImage: "message")
            }
            .tag(2)
            
            // Timer tab
            NavigationView {
                TimerView(workoutExercises: [])
            }
            .tabItem {
                Label("Таймер", systemImage: "timer")
            }
            .tag(3)
            
            // More tab (for additional screens)
            NavigationView {
                MoreOptionsView()
            }
            .tabItem {
                Label("Еще", systemImage: "ellipsis")
            }
            .tag(4)
        }
        .accentColor(.yellow)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainScreen()
}
