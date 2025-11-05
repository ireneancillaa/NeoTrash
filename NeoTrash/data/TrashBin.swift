//
//  TrashBin.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 26/10/25.
//

import Foundation

struct TrashBin: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let name: String
    
}
