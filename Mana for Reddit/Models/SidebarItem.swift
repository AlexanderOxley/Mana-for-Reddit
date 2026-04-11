//
//  SidebarItem.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case frontPage = "Front Page"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .frontPage: return "house.fill"
        }
    }
}
