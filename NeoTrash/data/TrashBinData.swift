//
//  TrashBinData.swift
//  NeoTrash
//
//  Created by Rizki Ramadhan Wira Saputra on 28/10/25.
//

import Foundation

struct TrashBinData: Codable, Identifiable {
    let id: UUID
    let trash_bin_id: UUID
    let smell: Double
    let us_organik: Double
    let us_nonorganik: Double
    let created_at: Date
}
