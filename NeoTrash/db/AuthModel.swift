//
//  AuthModel.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import Foundation
import SwiftUI
import Combine
import Supabase

class AuthModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ktaybvtmllhssroyjjnb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0YXlidnRtbGxoc3Nyb3lqam5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMTQ5ODMsImV4cCI6MjA3NTg5MDk4M30.jkT_NaWL2VxeUAq10fC6FVdhXJSobnDV1TGzNMf9szk"
    )
    
    func register(fullName: String, email: String, password: String, confirmPassword: String) async {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        guard email.contains("@gmail.com") else {
            errorMessage = "Email must be @gmail.com."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Sign up with Supabase Auth
            let response = try await client.auth.signUp(email: email, password: password)
            let user = response.user
            
            // Insert user profile (without storing password)
            try await client
                .from("users")
                .insert([
                    "id": user.id.uuidString,
                    "full_name": fullName,
                    "email": email
                ])
                .execute()
            
            isAuthenticated = true
            errorMessage = nil
            print("Register successfully with id: \(user.id.uuidString)")
        } catch {
            let nsError = error as NSError
            if nsError.localizedDescription.contains("User already registered") {
                errorMessage = "Email is already registered."
            } else if nsError.localizedDescription.contains("Invalid email") {
                errorMessage = "Please enter a valid email address."
            } else if nsError.localizedDescription.contains("Password should be at least") {
                errorMessage = "Password is too weak. Please use a stronger one."
            } else {
                errorMessage = "An unexpected error occurred. Please try again."
            }
        }
    }
    
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }
        
        guard email.contains("@gmail.com") else {
            errorMessage = "Email must be @gmail.com."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Check if email exists
            let result = try await client
                .from("users")
                .select("email")
                .eq("email", value: email)
                .execute()
            
            let data = result.data
            // Supabase returns an array JSON for select queries; check if it's empty
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]], json.isEmpty {
                errorMessage = "Email doesn't exist."
                return
            }
            
            // Sign in
            let response = try await client.auth.signIn(email: email, password: password)
            let user = response.user
            
            isAuthenticated = true
            errorMessage = nil
            print("Login successful for user ID: \(user.id)")
        } catch {
            let nsError = error as NSError
            if nsError.localizedDescription.contains("Email not found") {
                errorMessage = "Email doesn't exist."
            } else if nsError.localizedDescription.contains("Invalid login credentials") {
                errorMessage = "Incorrect password."
            } else {
                errorMessage = "An unexpected error occurred. Please try again."
            }
        }
    }
}

