//
//  Entrypoint.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct Entrypoint: View {
  @StateObject private var sidebarViewModel = SidebarColumnViewModel()
  @StateObject private var contentViewModel = ContentColumnViewModel(source: .frontPage)
  @StateObject private var detailViewModel = DetailColumnViewModel()

  var body: some View {
    NavigationSplitView {
      SidebarColumnView { source in
        sidebarViewModel.select(source)
        detailViewModel.setPost(nil)
        guard let source else { return }
        contentViewModel.setSource(source)
      }
    } content: {
      if let selectedFeed = sidebarViewModel.selectedItem {
        ContentColumnView(selectedFeed: selectedFeed)
      } else {
        ContentUnavailableView(
          "Select a feed",
          systemImage: "sidebar.left",
          description: Text("Choose a source in the sidebar.")
        )
      }
    } detail: {
      if let detailItem = detailViewModel.post {
        DetailColumnView(item: detailItem)
      } else {
        ContentUnavailableView(
          "Select a post",
          systemImage: "text.bubble",
          description: Text("Choose a post to read comments.")
        )
      }
    }
    .environmentObject(sidebarViewModel)
    .environmentObject(contentViewModel)
    .environmentObject(detailViewModel)
  }
}

#Preview {
  Entrypoint()
}
