//
//  TrashBinModel.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 26/10/25.
//

// TrashBinModel.swift
import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
class TrashBinModel: ObservableObject {
    
    @Published var trashBins: [TrashBin] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
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
        
        let newBin = TrashBin(
            id: UUID(),
            user_id: userID,
            name: name
        )
        
        do {
            try await client
                .from("trash_bins")
                .insert(newBin)
                .execute()
            
            trashBins.append(newBin)
            
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
}
