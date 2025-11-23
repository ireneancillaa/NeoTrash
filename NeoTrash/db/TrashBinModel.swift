//
//  TrashBinModel.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 26/10/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
class TrashBinModel: ObservableObject {
    
    @Published var trashBins: [TrashBin] = []
    @Published var latestSensorData: TrashBinData?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var timer: Timer?
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://ktaybvtmllhssroyjjnb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0YXlidnRtbGxoc3Nyb3lqam5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMTQ5ODMsImV4cCI6MjA3NTg5MDk4M30.jkT_NaWL2VxeUAq10fC6FVdhXJSobnDV1TGzNMf9szk"
    )
    
    private func getUserID() async -> UUID? {
        do {
            let user = try await client.auth.user()
            return user.id
        } catch {
            print("Error: User not logged in. \(error.localizedDescription)")
            errorMessage = "User not logged in."
            return nil
        }
    }

    func createTrashBin(name: String) async {
        guard let userID = await getUserID() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let newBinID = UUID()
        
        let newBin = TrashBin(
            id: newBinID,
            user_id: userID,
            name: name
        )
        
        do {
            try await client
                .from("trash_bins")
                .insert(newBin)
                .execute()
            
            trashBins.append(newBin)
            
            print("\(newBinID.uuidString.lowercased())")
            
        } catch {
            print("Error creating trash bin: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchTrashBins() async {
        guard let userID = await getUserID() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [TrashBin] = try await client
                .from("trash_bins")
                .select()
                .eq("user_id", value: userID)
                .execute()
                .value

            self.trashBins = response
            
        } catch {
            print("Error fetching trash bins: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func fetchLatestSensorData(binID: UUID) async {
            do {
                let response: [TrashBinData] = try await client
                    .from("trash_bin_data")
                    .select()
                    .eq("trash_bin_id", value: binID)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                    .value

                if let data = response.first {
                    self.latestSensorData = data
                    print("🔄 Data Update: Bau \(data.smell), Org \(data.us_organik)%")
                }
                
            } catch {
                print("Error fetching sensor data: \(error.localizedDescription)")
            }
        }
        
        func startMonitoring(binID: UUID) {
            stopMonitoring()
            
            Task {
                await fetchLatestSensorData(binID: binID)
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                Task {
                    await self?.fetchLatestSensorData(binID: binID)
                }
            }
        }
        
        func stopMonitoring() {
            timer?.invalidate()
            timer = nil
        }
}
