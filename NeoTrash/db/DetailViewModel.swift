//
//  DetailViewModel.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 28/10/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    
    @Published var latestData: TrashBinData?
    @Published var isLoading = false
    @Published var isSendingSprayCommand: Bool = false
    @Published var isOpeningOrganic: Bool = false
    @Published var isOpeningNonOrganic: Bool = false
    
    @Published var errorMessage: String?
    
    private var timer: Timer?
    let trashBin: TrashBin
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://ktaybvtmllhssroyjjnb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0YXlidnRtbGxoc3Nyb3lqam5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMTQ5ODMsImV4cCI6MjA3NTg5MDk4M30.jkT_NaWL2VxeUAq10fC6FVdhXJSobnDV1TGzNMf9szk"
    )
    
    private var realtimeChannel: RealtimeChannelV2?
    
    init(trashBin: TrashBin) {
        self.trashBin = trashBin
    }
    
    func startMonitoring() {
        Task { await fetchLatestData() }
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchLatestData()
            }
        }
    }
        
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func fetchLatestData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [TrashBinData] = try await client
                .from("trash_bin_data")
                .select()
                .eq("trash_bin_id", value: trashBin.id)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            self.latestData = response.first
            
        } catch {
            let errorDesc = error.localizedDescription
            print("Error fetching latest data: \(errorDesc)")
            errorMessage = "Gagal mengambil data: \(errorDesc)"
        }
        isLoading = false
    }

    func sprayPerfume() async {
        guard !isSendingSprayCommand else { return }
        
        isSendingSprayCommand = true
        errorMessage = nil
        
        do {
            try await client
                .from("trash_bins")
                .update(["servo_stella": true])
                .eq("id", value: trashBin.id)
                .execute()
            
            print("Spray command send succesfully")
            
        } catch {
            let errorDesc = error.localizedDescription
            print("Error sending spray command: \(errorDesc)")
            errorMessage = "Gagal mengirim perintah spray: \(errorDesc)"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSendingSprayCommand = false
        }
    }
    
    func openOrganicBin() async {
        guard !isOpeningOrganic else { return }
        isOpeningOrganic = true
        errorMessage = nil
        
        do {
            try await client
                .from("trash_bins")
                .update(["servo_organik": true])
                .eq("id", value: trashBin.id)
                .execute()
            
            print("Perintah buka Organik terkirim")
        } catch {
            print("Error opening organic bin: \(error.localizedDescription)")
            errorMessage = "Gagal membuka tong Organik"
        }
        
        try? await Task.sleep(nanoseconds: 30_000_000_000)
        
        self.isOpeningOrganic = false
    }
    
    func openNonOrganicBin() async {
        guard !isOpeningNonOrganic else { return }
        isOpeningNonOrganic = true
        errorMessage = nil
        
        do {
            try await client
                .from("trash_bins")
                .update(["servo_nonorganik": true])
                .eq("id", value: trashBin.id)
                .execute()
            
            print("Perintah buka Non-Organik terkirim")
        } catch {
            print("Error opening non-organic bin: \(error.localizedDescription)")
            errorMessage = "Gagal membuka tong Non-Organik"
        }
        
        try? await Task.sleep(nanoseconds: 30_000_000_000)
        
        self.isOpeningNonOrganic = false
    }
    
    func deleteTrashBin() async -> Bool {
            isLoading = true
            do {
                try await client
                    .from("trash_bins")
                    .delete()
                    .eq("id", value: trashBin.id)
                    .execute()
    
                isLoading = false
                return true
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                return false
            }
        }
    
    func subscribeToDataChanges() {
        let channelName = "public:trash_bin_data:id=\(trashBin.id)"
        realtimeChannel = client.realtimeV2.channel(channelName)

        Task {
            let changeStream = realtimeChannel?.postgresChange(AnyAction.self,
                                                                      schema: "public",
                                                                      table: "trash_bin_data")
            
            try? await realtimeChannel?.subscribeWithError()
            
            if let stream = changeStream {
                for await change in stream {
                    print("Realtime: Perubahan terdeteksi - \(change)")
                    
                    await fetchLatestData()
                }
            }
        }
    }

    func unsubscribeFromChanges() {
        Task {
            await realtimeChannel?.unsubscribe()
            realtimeChannel = nil
        }
    }
}
