//
//  SplashScreen.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 17/09/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var showCircle = false
    @State private var showTrashBin = false
    @State private var trashOffset: CGFloat = -200
    @State private var trashOpacity: Double = 1
    @State private var fadeOutBin = false
    @State private var isActive = false
    
    func startAnimationSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCircle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showTrashBin = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            fadeOutBin = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                isActive = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            if isActive {
                LoginPage(viewModel: AuthModel())
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.1)).animation(.easeInOut(duration: 0.8)),
                        removal: .opacity.animation(.easeOut(duration: 0.5))
                    ))
                    .animation(.easeInOut(duration: 0.8), value: isActive)
            } else {
                ZStack {
                    Color("splash").ignoresSafeArea()
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: showCircle ? 2000 : 0, height: showCircle ? 2000 : 0)
                        .animation(.easeInOut(duration: 1.2), value: showCircle)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .center) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 300)
                                .opacity(showTrashBin ? (fadeOutBin ? 0 : 1) : 0)
                                .offset(y: showTrashBin ? 0 : geometry.size.height / 3)
                                .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: showTrashBin)
                                .animation(.easeInOut(duration: 1.5), value: fadeOutBin)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .onAppear {
                    startAnimationSequence()
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
