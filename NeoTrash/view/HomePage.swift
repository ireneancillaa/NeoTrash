//
//  HomePage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 01/10/25.
//

import SwiftUI

struct HomePage: View {
    @StateObject private var trashBinModel = TrashBinModel()
    
    @State private var isShowingAddBinAlert = false
    @State private var newBinName: String = ""
    
    var body: some View {
        TabView {
            NavigationStack {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack(spacing: 10) {
                        ZStack {
                            HStack {
                                Spacer()
                                NavigationLink(destination: AboutUsPage()) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.white)
                                        .font(.system(size: 25))
                                }
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text("Neo")
                                    .foregroundColor(Color("splash"))
                                    .font(.system(size: 30, weight: .black))
                                Text("Trash")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30, weight: .black))
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        ScrollView {
                            VStack {
                                if trashBinModel.isLoading {
                                    ProgressView()
                                        .controlSize(.large)
                                        .padding(.top, 50)
                                        .tint(.white)
                                    
                                } else if trashBinModel.trashBins.isEmpty {
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
                                        ForEach(trashBinModel.trashBins) { bin in
                                            
                                            NavigationLink(destination: DetailPage(trashBin: bin)) {
                                                VStack {
                                                    Text(bin.name)
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
                        newBinName = ""
                        isShowingAddBinAlert = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 35))
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(24)
                }
                .onAppear {
                    Task {
                        await trashBinModel.fetchTrashBins()
                    }
                }
                .alert("Add New Trash Bin", isPresented: $isShowingAddBinAlert) {
                    TextField("E.g., Trash Bin Dapur", text: $newBinName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Button("Cancel", role: .cancel) { }
                    Button("Save") {
                        if !newBinName.isEmpty {
                            Task {
                                await trashBinModel.createTrashBin(name: newBinName)
                            }
                        }
                    }
                } message: {
                    Text("Please enter a name for your new trash bin.")
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            
            NotificationPage()
                .tabItem {
                    Label("Notification", systemImage: "bell.fill")
                }
            
            ProfilePage(viewModel: AuthModel())
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    HomePage()
}
