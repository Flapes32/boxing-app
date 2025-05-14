//
//  SignUpEmailView.swift
//  final
//
//  Created by  Apple on 14.04.2025.
//

import SwiftUI
import FirebaseAuth

struct SignUpEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // Состояние ошибки
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Состояние загрузки
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0.09019608051, blue: 0.09019608051, alpha: 1)), Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Заголовок
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Регистрация")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Пустая кнопка для выравнивания
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal)
                
                // Форма регистрации
                ScrollView {
                    VStack(spacing: 20) {
                        // Имя пользователя
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Полное имя")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("", text: $fullName)
                                .padding()
                                .background(Color(.systemGray6).opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Email поле
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("", text: $email)
                                .padding()
                                .background(Color(.systemGray6).opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Пароль поле
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                if showPassword {
                                    TextField("", text: $password)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("", text: $password)
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Подтверждение пароля
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Подтвердите пароль")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("", text: $confirmPassword)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("", text: $confirmPassword)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Кнопка регистрации
                Button(action: {
                    signUp()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 55)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 5, x: 0, y: 3)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("Создать аккаунт")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || fullName.isEmpty)
                .opacity(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || fullName.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
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
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
    
    // Метод для регистрации
    private func signUp() {
        // Валидация данных
        if password != confirmPassword {
            errorMessage = "Пароли не совпадают"
            withAnimation {
                showError = true
            }
            return
        }
        
        if password.count < 6 {
            errorMessage = "Пароль должен содержать не менее 6 символов"
            withAnimation {
                showError = true
            }
            return
        }
        
        isLoading = true
        showError = false
        
        // Скрытие клавиатуры
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        Task {
            do {
                // Создание пользователя через Firebase
                let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
                
                // Здесь можно добавить дополнительные данные пользователя в Firestore
                // Например, сохранить fullName
                
                // Успешная регистрация
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch let error as AuthenticationError {
                // Обработка ошибок аутентификации
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.message
                    withAnimation {
                        showError = true
                    }
                }
            } catch {
                // Обработка других ошибок
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Ошибка при регистрации: \(error.localizedDescription)"
                    withAnimation {
                        showError = true
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpEmailView()
        .preferredColorScheme(.dark)
}
