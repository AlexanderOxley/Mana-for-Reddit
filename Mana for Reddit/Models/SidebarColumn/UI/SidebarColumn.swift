//
//  SidebarColumn.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct SidebarColumn {
  var items: [Source] = Source.defaults
  var selectedItem: Source? = .frontPage

  mutating func select(_ item: Source?) {
    selectedItem = item
  }
}
