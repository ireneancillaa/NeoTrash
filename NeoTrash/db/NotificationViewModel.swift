//
//  NotificationViewModel.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 08/12/25.
//

import SwiftUI
import Foundation
import Supabase
import Combine

struct NotificationModel: Codable, Identifiable {
    let id: UUID
    let title: String
    let message: String
    let created_at: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: created_at)
    }
}

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://ktaybvtmllhssroyjjnb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0YXlidnRtbGxoc3Nyb3lqam5iIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDMxNDk4MywiZXhwIjoyMDc1ODkwOTgzfQ.Tho1wtr8Pbzj3TDLJ1JUoDE2GgVNVRj0tfO_oHe_eDY"
    )
    
    private var realtimeChannel: RealtimeChannelV2?

    func fetchNotifications() async {
        isLoading = true
        do {
            let response: [NotificationModel] = try await client
                .from("notifications")
                .select()
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            
            self.notifications = response
        } catch {
            print("Error fetching notifications: \(error)")
        }
        isLoading = false
    }
    
    func deleteNotification(id: UUID) async {
            do {
                try await client
                    .from("notifications")
                    .delete()
                    .eq("id", value: id)
                    .execute()
                print("Notifikasi berhasil dihapus dari database")
            } catch {
                print("Gagal menghapus notifikasi: \(error)")
            }
        }

    func subscribeToAlerts() {
        let channel = client.realtimeV2.channel("public:notifications")
        let insertion = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "notifications",
            filter: nil
        )
        
        Task {
            await channel.subscribe()
            
            for await change in insertion {
                switch change {
                case .insert(let record):
                    do {
                        let data = try JSONDecoder().decode(NotificationModel.self, from: JSONSerialization.data(withJSONObject: record.record))
                        withAnimation {
                            self.notifications.insert(data, at: 0)
                        }
                        
                        print("ALERT BARU DITERIMA: \(data.title)")

                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                        
                    } catch {
                        print("Gagal decode notifikasi baru: \(error)")
                    }
                default: break
                }
            }
        }
        self.realtimeChannel = channel
    }
    
    func unsubscribe() {
        Task {
            await realtimeChannel?.unsubscribe()
        }
    }
}
