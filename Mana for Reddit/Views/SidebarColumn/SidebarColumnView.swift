//
//  SidebarColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct SidebarColumnView: View {
  @EnvironmentObject private var viewModel: SidebarColumnViewModel
  let onSelect: (Source?) -> Void

  var body: some View {
    List(
      viewModel.items,
      selection: Binding(
        get: { viewModel.selectedItem },
        set: { onSelect($0) }
      )
    ) { item in
      Label(item.title, systemImage: item.icon)
        .tag(item)
    }
    .navigationTitle("Mana")
  }
}

#Preview {
  let sidebar = SidebarColumnViewModel()
  NavigationStack {
    SidebarColumnView { sidebar.select($0) }
  }
  .environmentObject(sidebar)
}
