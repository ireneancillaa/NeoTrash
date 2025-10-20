//
//  HomePage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 01/10/25.
//

import SwiftUI

struct HomePage: View {
    @State private var trashBins: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    HStack(spacing: 0) {
                        Text("Neo")
                            .foregroundColor(Color("splash"))
                            .font(.system(size: 30, weight: .black))
                        Text("Trash")
                            .foregroundColor(.white)
                            .font(.system(size: 30, weight: .black))
                    }
                    
                    ScrollView {
                        VStack {
                            if trashBins.isEmpty {
                                GeometryReader { geometry in
                                    VStack {
                                        Text("Empty")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .contentShape(Rectangle())
                                }
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(trashBins, id: \.self) { bin in
                                        NavigationLink(destination: DetailPage(trashName: bin)) {
                                            VStack {
                                                Text(bin)
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                                Image("trash")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 150)
                                            .background(Color.black.opacity(0.8))
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("splash"), lineWidth: 5))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .padding(.top)
                }
                
                Button(action: {
                    let newBin = "Trash \(trashBins.count + 1)"
                    trashBins.append(newBin)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 35))
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(24)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            NotificationPage()
                .tabItem {
                    Label("Notification", systemImage: "bell.fill")
                }
            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    HomePage()
}
