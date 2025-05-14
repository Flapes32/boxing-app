import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: UUID(), text: "Привет! Я твой виртуальный тренер по боксу. Чем могу помочь сегодня?", isFromUser: false, timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(id: UUID(), text: "Хочу улучшить технику джеба", isFromUser: true, timestamp: Date().addingTimeInterval(-3500)),
        ChatMessage(id: UUID(), text: "Отлично! Вот несколько советов для улучшения джеба:\n\n1. Держите локоть близко к телу\n2. Полностью выпрямляйте руку\n3. Поворачивайте кулак в конце удара\n4. Возвращайте руку сразу после удара\n\nХотите видео с демонстрацией?", isFromUser: false, timestamp: Date().addingTimeInterval(-3400))
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Сообщение...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.yellow)
                        .padding(10)
                }
            }
            .padding()
        }
        .navigationTitle("Тренер")
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(id: UUID(), text: messageText, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear text field
        messageText = ""
        
        // Simulate coach response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let coachResponse = ChatMessage(
                id: UUID(),
                text: generateCoachResponse(to: userMessage.text),
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(coachResponse)
        }
    }
    
    func generateCoachResponse(to message: String) -> String {
        // Simple response generation based on keywords
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("привет") || lowercasedMessage.contains("здравствуй") {
            return "Привет! Чем я могу помочь сегодня?"
        } else if lowercasedMessage.contains("джеб") || lowercasedMessage.contains("удар") {
            return "Для улучшения ударной техники рекомендую работать над точностью и скоростью. Начните с медленных повторений, постепенно увеличивая темп."
        } else if lowercasedMessage.contains("защит") {
            return "Хорошая защита - основа бокса. Работайте над блоками, уклонами и передвижением. Не забывайте держать руки высоко для защиты головы."
        } else if lowercasedMessage.contains("тренировк") || lowercasedMessage.contains("упражнен") {
            return "Я могу предложить несколько упражнений для вашего уровня. Хотите сфокусироваться на технике, силе или выносливости?"
        } else {
            return "Интересный вопрос! Давайте обсудим это подробнее. Что конкретно вас интересует в боксе?"
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading) {
                Text(message.text)
                    .padding(12)
                    .background(message.isFromUser ? Color.yellow : Color(.systemGray5))
                    .foregroundColor(message.isFromUser ? .black : .primary)
                    .cornerRadius(16)
                
                Text(formatDate(message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
}
