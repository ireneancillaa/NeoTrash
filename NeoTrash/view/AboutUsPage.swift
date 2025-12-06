//
//  AboutUsPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 06/12/25.
//

import SwiftUI

struct AboutUsPage: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Brief singkat aplikasi
                        Text("NeoTrash is a smart waste management app designed to help users sort, track, and recycle their waste efficiently. Our goal is to make sustainable living simple and accessible.")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)

                        // Developer Cards
                        VStack(spacing: 20) {

                            DeveloperCard(
                                imageName: "irene",
                                name: "Irene Ancilla Chow",
                                role: "Frontend Developer",
                                description: "Designing and developing the NeoTrash interface and ensuring smooth user interactions."
                            )

                            DeveloperCard(
                                imageName: "adit",
                                name: "Aditya Wedo Pangestu",
                                role: "Technical",
                                description: "Responsible for developing and managing the IoT system for NeoTrash’s smart trash bins."
                            )

                            DeveloperCard(
                                imageName: "rizki",
                                name: "Rizki Ramadhan W. Saputra",
                                role: "Backend Developer",
                                description: "Handles backend infrastructure, data flow, and ensures stable API integration for NeoTrash."
                            )
                        }

                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("About Us")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}


struct DeveloperCard: View {
    let imageName: String
    let name: String
    let role: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipShape(Circle())

            Text(name)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))

            Text(role)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 15))

            Text(description)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .font(.system(size: 14))
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("splash").opacity(0.15))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AboutUsPage()
}
