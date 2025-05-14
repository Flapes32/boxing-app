import SwiftUI

struct LoginView: View {
    // Сервис данных
    @ObservedObject private var dataService = DataService.shared
    
    // Состояние формы
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showPassword = false
    
    // Состояние ошибки
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Фоновый цвет
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0.09019608051, blue: 0.09019608051, alpha: 1)), Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Логотип и заголовок
                VStack(spacing: 15) {
                    // Логотип
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(Color.yellow.opacity(0.6))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "figure.boxing")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                    
                    // Заголовок
                    Text("БОКСЕРСКИЙ ТРЕНЕР")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .padding(.top, 50)
                
                // Форма авторизации
                VStack(spacing: 20) {
                    // Поле email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Введите email", text: $email)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Поле пароля
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Пароль")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            if showPassword {
                                TextField("Введите пароль", text: $password)
                                    .foregroundColor(.white)
                            } else {
                                SecureField("Введите пароль", text: $password)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    // Опция "Запомнить меня"
                    HStack {
                        Button(action: {
                            rememberMe.toggle()
                        }) {
                            HStack {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? .yellow : .gray)
                                
                                Text("Запомнить меня")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Действие для восстановления пароля
                        }) {
                            Text("Забыли пароль?")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 30)
                
                // Кнопка входа
                Button(action: {
                    handleLogin()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 55)
                            .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        if dataService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("ВОЙТИ")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .disabled(dataService.isLoading || email.isEmpty || password.isEmpty)
                
                // Кнопка регистрации
                Button(action: {
                    // Действие для регистрации
                }) {
                    Text("Нет аккаунта? Зарегистрироваться")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Информация для тестирования
                VStack(spacing: 5) {
                    Text("Для тестирования используйте:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Email: test@example.com")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Пароль: password")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
            
            // Сообщение об ошибке
            if showError {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showError = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showError)
                .zIndex(1)
            }
        }
        .onReceive(dataService.$error.compactMap { $0 }) { error in
            errorMessage = error.message
            withAnimation {
                showError = true
            }
        }
    }
    
    // Обработка нажатия кнопки входа
    private func handleLogin() {
        // Скрыть клавиатуру
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Вызов метода авторизации через Firebase
        Task {
            await dataService.login(email: email, password: password)
        }
    }
}

// Расширение для предварительного просмотра
#Preview {
    LoginView()
}

