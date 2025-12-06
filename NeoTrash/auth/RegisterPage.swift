//
//  RegisterPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI

struct RegisterPage: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSecure: Bool = true
    @State private var isSecureConfirm: Bool = true
    @State private var showAlert: Bool = false
    @State private var navigateToHome = false
    
    @ObservedObject var viewModel: AuthModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 25) {
                        Text("Welcome!")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .padding(.bottom, 40)
                        
                        VStack(spacing: 16) {
                            ZStack(alignment: .leading) {
                                if fullName.isEmpty {
                                    Text("Full Name")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontWeight(.bold)
                                }
                                TextField("", text: $fullName)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .autocapitalization(.words)
                            }
                            .padding()
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("splash"), lineWidth: 1)
                            )
                            
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
                                    .stroke(Color("splash"), lineWidth: 1)
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
                                    .stroke(Color("splash"), lineWidth: 1)
                            )
                            
                            ZStack(alignment: .leading) {
                                if confirmPassword.isEmpty {
                                    Text("Confirm Password")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    if isSecureConfirm {
                                        SecureField("", text: $confirmPassword)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    } else {
                                        TextField("", text: $confirmPassword)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                    Button(action: {
                                        isSecureConfirm.toggle()
                                    }) {
                                        Image(systemName: isSecureConfirm ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("splash"), lineWidth: 1)
                            )
                        }
                        
                        Button {
                            // Validation before calling register
                            // 1. fullName tidak boleh mengandung angka.
                            if fullName.rangeOfCharacter(from: .decimalDigits) != nil {
                                viewModel.errorMessage = "Full Name cannot contain numbers."
                                showAlert = true
                                return
                            }
                            // 2. Semua field tidak boleh hanya berisi spasi atau kosong.
                            if fullName.trimmingCharacters(in: .whitespaces).isEmpty ||
                                email.trimmingCharacters(in: .whitespaces).isEmpty ||
                                password.trimmingCharacters(in: .whitespaces).isEmpty ||
                                confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty {
                                viewModel.errorMessage = "All fields are required and cannot be empty."
                                showAlert = true
                                return
                            }
                            // 3. email harus sesuai format email umum menggunakan regex sederhana.
                            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
                            if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
                                viewModel.errorMessage = "Please enter a valid email address."
                                showAlert = true
                                return
                            }
                            // 4. password dan confirmPassword harus sama
                            if password != confirmPassword {
                                viewModel.errorMessage = "Password and Confirm Password do not match."
                                showAlert = true
                                return
                            }
                            
                            Task {
                                let success = await viewModel.register(fullName: fullName,email: email,password: password, confirmPassword: confirmPassword
                                                                )
                                if success {
                                    navigateToHome = true
                                } else {
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
                                Text("Register")
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
                    Text("Already have an account?")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    NavigationLink(destination: LoginPage(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)) {
                        Text("Login here.")
                            .foregroundColor(Color("splash"))
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePage()
            }
            .alert("Error", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            })
        }
    }
}

#Preview {
    RegisterPage(viewModel: AuthModel())
}
