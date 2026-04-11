//
//  UISidebarColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Combine
import Foundation

@MainActor
final class SidebarColumnViewModel: ObservableObject {
  @Published var items: [Source] = Source.defaults
  @Published var selectedItem: Source? = .frontPage

  func select(_ item: Source?) {
    selectedItem = item
  }
}
