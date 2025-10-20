//
//  NeoTrashApp.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 17/09/25.
//

import SwiftUI

@main
struct NeoTrashApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                LoginPage(viewModel: AuthModel())
            }
        }
    }
}
