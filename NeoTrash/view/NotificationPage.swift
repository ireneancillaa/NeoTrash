//
//  NotificationPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI
import Combine

struct NotificationItem: Identifiable {
    let id = UUID()
    let trashName: String
    let message: String
    let date: String
}

struct NotificationPage: View {
    @StateObject private var viewModel = NotificationViewModel()
    
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Notification")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    Divider()
                        .background(Color.gray.opacity(0.5))
                        .padding(.bottom, 10)

                    if viewModel.isLoading && viewModel.notifications.isEmpty {
                        ProgressView().tint(.white).padding(.top, 50)
                        Spacer()
                    } else if viewModel.notifications.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No notifications yet")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.notifications) { item in
                                NotificationCard(item: NotificationItem(
                                    trashName: item.title,
                                    message: item.message,
                                    date: item.formattedDate
                                ))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            }
                            .onDelete(perform: deleteNotification)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .refreshable {
                            await viewModel.fetchNotifications()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task { await viewModel.fetchNotifications() }
                viewModel.subscribeToAlerts()
            }
            .onDisappear {
                viewModel.unsubscribe()
            }
        }
    }
    
    func deleteNotification(at offsets: IndexSet) {
        withAnimation {
            viewModel.notifications.remove(atOffsets: offsets)
        }
    }
}

struct NotificationCard: View {
    let item: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "trash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white.opacity(0.8))
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.trashName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(item.date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(item.message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    NotificationPage()
}
