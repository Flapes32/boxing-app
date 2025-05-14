import SwiftUI

struct SocialChatView: View {
    @State private var messageText = ""
    @State private var showingAttachmentMenu = false
    @State private var showingCreateGroup = false
    
    // Модель сообщений
    @State private var messages: [ChatMessageModel] = [
        ChatMessageModel(id: "1", sender: "Константин", time: "02:32", text: "Отлично! Только что закончил 12 раундов", isCurrentUser: false, attachmentType: .workout, attachmentText: "Тренировка выносливости", attachmentDetail: "45 минут"),
        ChatMessageModel(id: "2", sender: "Анна", time: "02:32", text: "Кто хочет присоединиться к групповой тренировке?", isCurrentUser: false)
    ]
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Верхняя панель
                HStack {
                    Text("Чат")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showingCreateGroup = true
                    }) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.yellow)
                            Text("Создать группу")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Список сообщений
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(messages, id: \.id) { message in
                            ChatMessageView(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                // Панель ввода сообщения
                HStack(spacing: 10) {
                    Button(action: {
                        showingAttachmentMenu = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                    }
                    
                    TextField("Сообщение...", text: $messageText)
                        .padding(10)
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAttachmentMenu) {
            AttachmentMenuView(onSelect: { attachmentType in
                handleAttachment(attachmentType)
                showingAttachmentMenu = false
            })
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupView(onCreateGroup: { groupName in
                // Обработка создания группы
                showingCreateGroup = false
            })
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = ChatMessageModel(
            id: UUID().uuidString,
            sender: "Вы",
            time: formatCurrentTime(),
            text: messageText,
            isCurrentUser: true
        )
        
        messages.append(newMessage)
        messageText = ""
    }
    
    func handleAttachment(_ type: AttachmentType) {
        // Обработка прикрепления
        print("Выбран тип прикрепления: \(type)")
    }
    
    func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

// Модель сообщения
struct ChatMessageModel: Identifiable {
    let id: String
    let sender: String
    let time: String
    let text: String
    let isCurrentUser: Bool
    var attachmentType: AttachmentType? = nil
    var attachmentText: String? = nil
    var attachmentDetail: String? = nil
}

// Типы прикреплений
enum AttachmentType {
    case photo
    case workout
    case achievement
    case challenge
}

// Представление сообщения
struct ChatMessageView: View {
    let message: ChatMessageModel
    
    var body: some View {
        VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 5) {
            // Информация о отправителе
            if !message.isCurrentUser {
                HStack {
                    Text(message.sender)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(message.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Текст сообщения
            HStack {
                if message.isCurrentUser {
                    Spacer()
                }
                
                Text(message.text)
                    .padding(12)
                    .background(message.isCurrentUser ? Color.yellow : Color(.systemGray6).opacity(0.3))
                    .foregroundColor(message.isCurrentUser ? .black : .white)
                    .cornerRadius(16)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !message.isCurrentUser {
                    Spacer()
                }
            }
            
            // Прикрепление (если есть)
            if let attachmentType = message.attachmentType,
               let attachmentText = message.attachmentText {
                HStack {
                    if message.isCurrentUser {
                        Spacer()
                    }
                    
                    AttachmentView(type: attachmentType, title: attachmentText, detail: message.attachmentDetail)
                    
                    if !message.isCurrentUser {
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// Представление прикрепления
struct AttachmentView: View {
    let type: AttachmentType
    let title: String
    let detail: String?
    
    var body: some View {
        HStack {
            // Иконка в зависимости от типа
            Image(systemName: iconForType(type))
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(colorForType(type)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(12)
        .frame(maxWidth: 250, alignment: .leading)
    }
    
    func iconForType(_ type: AttachmentType) -> String {
        switch type {
        case .photo:
            return "photo"
        case .workout:
            return "figure.walk"
        case .achievement:
            return "trophy.fill"
        case .challenge:
            return "flame.fill"
        }
    }
    
    func colorForType(_ type: AttachmentType) -> Color {
        switch type {
        case .photo:
            return .blue
        case .workout:
            return .green
        case .achievement:
            return .yellow
        case .challenge:
            return .red
        }
    }
}

// Меню прикреплений
struct AttachmentMenuView: View {
    let onSelect: (AttachmentType) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Прикрепить")
                .font(.headline)
                .padding(.top)
            
            HStack {
                Spacer()
                
                Button(action: {
                    onSelect(.photo)
                }) {
                    AttachmentOption(icon: "photo", title: "Фото", color: .blue)
                }
                
                Spacer()
                
                Button(action: {
                    onSelect(.workout)
                }) {
                    AttachmentOption(icon: "figure.walk", title: "Тренировка", color: .green)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    onSelect(.achievement)
                }) {
                    AttachmentOption(icon: "trophy.fill", title: "Достижение", color: .yellow)
                }
                
                Spacer()
                
                Button(action: {
                    onSelect(.challenge)
                }) {
                    AttachmentOption(icon: "flame.fill", title: "Вызов", color: .red)
                }
                
                Spacer()
            }
            
            Button(action: {
                // Закрыть меню
            }) {
                Text("Готово")
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
    }
}

struct AttachmentOption: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(10)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

// Экран создания группы
struct CreateGroupView: View {
    @State private var groupName = ""
    @State private var selectedFriends: [String] = []
    let onCreateGroup: (String) -> Void
    
    // Пример списка друзей
    let friends = ["Анна", "Константин", "Михаил", "Елена", "Сергей"]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Название группы", text: $groupName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Text("Выберите участников:")
                    .font(.headline)
                    .padding(.top)
                
                List {
                    ForEach(friends, id: \.self) { friend in
                        HStack {
                            Text(friend)
                            Spacer()
                            if selectedFriends.contains(friend) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFriends.contains(friend) {
                                selectedFriends.removeAll { $0 == friend }
                            } else {
                                selectedFriends.append(friend)
                            }
                        }
                    }
                }
                
                Button(action: {
                    if !groupName.isEmpty {
                        onCreateGroup(groupName)
                    }
                }) {
                    Text("Создать группу")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(groupName.isEmpty || selectedFriends.isEmpty)
                .padding(.bottom)
            }
            .navigationTitle("Новая группа")
            .navigationBarItems(trailing: Button("Отмена") {
                // Закрыть экран
            })
        }
    }
}

#Preview {
    SocialChatView()
}
