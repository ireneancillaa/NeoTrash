//
//  DetailPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI

struct DetailPage: View {
    let trashName: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text(trashName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("splash"))
            }
        }
        .navigationTitle("Trash Detail")
    }
}

#Preview {
    DetailPage(trashName: "1")
}
