//
//  ProfilePage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI

struct ProfilePage: View {
    @ObservedObject var viewModel: AuthModel
    @State private var goToLogin = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Profile")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -15)
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 200))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                // FULL NAME
                VStack(alignment: .leading, spacing: 12) {
                    Text("Full Name")
                        .foregroundColor(.gray)
                    
                    Text(viewModel.fullName.isEmpty ? "Not available" : viewModel.fullName)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(.horizontal)
                
                // EMAIL
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email")
                        .foregroundColor(.gray)
                    
                    Text(viewModel.email.isEmpty ? "Not available" : viewModel.email)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // LOGOUT BUTTON AT BOTTOM
                Button(action: {
                    viewModel.logout()
                    goToLogin = true
                }) {
                    Text("Logout")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("splash"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding([.horizontal, .bottom])
            }
            .padding()
            .task {
                await viewModel.fetchUser()
            }
        }
        .fullScreenCover(isPresented: $goToLogin) {
            LoginPage(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationView {
        ProfilePage(viewModel: AuthModel())
    }
}
