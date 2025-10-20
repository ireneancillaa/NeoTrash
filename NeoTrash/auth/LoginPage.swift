//
//  LoginPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI

struct LoginPage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var showAlert: Bool = false
    
    @ObservedObject var viewModel: AuthModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 25) {
                        Text("Welcome Back!")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .padding(.bottom, 40)
                        
                        VStack(spacing: 16) {
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("Email")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontWeight(.bold)
                                }
                                TextField("", text: $email)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("splash"), lineWidth: 2)
                            )

                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("Password")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    if isSecure {
                                        SecureField("", text: $password)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    } else {
                                        TextField("", text: $password)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                    Button(action: {
                                        isSecure.toggle()
                                    }) {
                                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("splash"), lineWidth: 2)
                            )
                        }
                        
                        Button {
                            Task {
                                await viewModel.login(email: email, password: password)
                                if viewModel.errorMessage != nil {
                                    showAlert = true
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("splash"))
                                    .cornerRadius(8)
                            } else {
                                Text("Login")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("splash"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                HStack {
                    Text("New to NeoTrash?")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    NavigationLink(destination: RegisterPage(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)) {
                        Text("Register here.")
                            .foregroundColor(Color("splash"))
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                GeometryReader { geometry in
                    if showAlert, let message = viewModel.errorMessage {
                        VStack {
                            VStack {
                                Text(message)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(Color("splash").opacity(0.3))
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showAlert)
                            }
                            .padding(.horizontal)
                            .padding(.top, geometry.safeAreaInsets.top + 10)

                            Spacer()
                        }
                        .ignoresSafeArea(edges: .top)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showAlert = false
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                HomePage()
            }
        }
    }
}

#Preview {
    LoginPage(viewModel: AuthModel())
}
