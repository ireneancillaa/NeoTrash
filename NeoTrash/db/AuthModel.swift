//
//  AuthModel.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
class AuthModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://ktaybvtmllhssroyjjnb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0YXlidnRtbGxoc3Nyb3lqam5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMTQ5ODMsImV4cCI6MjA3NTg5MDk4M30.jkT_NaWL2VxeUAq10fC6FVdhXJSobnDV1TGzNMf9szk"
    )

    func register(fullName: String, email: String, password: String, confirmPassword: String) async -> Bool {
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard validateInput(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword) else {
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let metaData: [String: AnyJSON] = [
            "full_name": .string(cleanFullName)
                ]
            
            try await client.auth.signUp(
                email: cleanEmail,
                password: password,
                data: metaData
            )
            
            isAuthenticated = true
            print("Register successfully for: \(cleanEmail)")
            return true
            
        } catch {
            handleAuthError(error)
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields."
            return false
        }
        
        guard cleanEmail.contains("@gmail.com") else {
            errorMessage = "Email must be @gmail.com."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await client.auth.signIn(email: cleanEmail, password: password)
            
            isAuthenticated = true
            print("Login successful for user ID: \(response.user.id)")
            return true
            
        } catch {
            handleAuthError(error)
            return false
        }
    }
    
    private func validateInput(fullName: String, email: String, password: String, confirmPassword: String) -> Bool {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill all fields."
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }
        
        guard email.contains("@gmail.com") else {
            errorMessage = "Email must be @gmail.com."
            return false
        }
        return true
    }

    private func handleAuthError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .weakPassword:
                errorMessage = "Password is too weak. Please use a stronger one."
            default:
                errorMessage = authError.localizedDescription
            }
        } else {
            let nsError = error as NSError
            if nsError.localizedDescription.contains("User already registered") {
                errorMessage = "Email is already registered."
            } else if nsError.localizedDescription.contains("Invalid login credentials") {
                errorMessage = "Incorrect email or password."
            } else if nsError.localizedDescription.contains("Email not found") {
                errorMessage = "Email not found."
            } else {
                errorMessage = "An unexpected error occurred. Please try again."
                print("Unexpected Error: \(error.localizedDescription)")
            }
        }
    }
}
