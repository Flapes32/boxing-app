//
//  AuthenticationView.swift
//  final
//
//  Created by  Apple on 14.04.2025.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var showSignInView: Bool = false
    @State private var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент
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
                
                Spacer()
                
                // Кнопки входа и регистрации
                VStack(spacing: 20) {
                    // Кнопка входа
                    Button(action: {
                        showSignInView = true
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
                            
                            Text("Войти")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Кнопка регистрации
                    Button(action: {
                        showSignUpView = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow, lineWidth: 2)
                                .frame(height: 55)
                            
                            Text("Создать аккаунт")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showSignInView) {
            SignInEmailView()
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSignUpView) {
            SignUpEmailView()
                .preferredColorScheme(.dark)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .preferredColorScheme(.dark)
    }
}
