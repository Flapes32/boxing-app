import SwiftUI

@main
struct BoxingApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .preferredColorScheme(.dark)
                .accentColor(.yellow)
                .onAppear {
                    print("DEBUG: Simplified MainScreen appeared")
                }
        }
    }
}

