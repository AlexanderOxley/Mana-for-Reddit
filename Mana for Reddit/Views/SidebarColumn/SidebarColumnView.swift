//
//  SidebarColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct SidebarColumnView: View {
  @EnvironmentObject private var viewModel: SidebarColumnViewModel
  @EnvironmentObject private var switcherViewModel: ContentSubredditSwitcherViewModel

  let onSelect: (Source?) -> Void

  var body: some View {
    List(selection: selectionBinding) {
      #if os(iOS)
        Section {
          Button("Search") {
            switcherViewModel.present()
          }
        }
      #endif

      Section("General") {
        Label(Source.frontPage.title, systemImage: Source.frontPage.icon)
          .tag(Source.frontPage)
      }

      Section("Recents") {
        ForEach(viewModel.recents) { item in
          Label(item.title, systemImage: item.icon)
            .tag(item)
            .contextMenu {
              Button(role: .destructive) {
                viewModel.removeSubreddit(item)
                onSelect(viewModel.selectedItem)
              } label: {
                Label("Remove", systemImage: "trash")
              }
            }
        }
      }
    }
  }

  private var selectionBinding: Binding<Source?> {
    Binding(
      get: { viewModel.selectedItem },
      set: { selected in
        Task { @MainActor in
          await Task.yield()
          viewModel.select(selected)
          onSelect(selected)
        }
      }
    )
  }
}

#Preview {
  let sidebar = SidebarColumnViewModel()
  NavigationStack {
    SidebarColumnView {
      sidebar.select($0)
    }
  }
  .environmentObject(sidebar)
}
