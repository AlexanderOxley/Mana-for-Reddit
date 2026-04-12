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
    List(selection: selectionBinding) {
      Section {
        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
            .foregroundStyle(.secondary)
          TextField("Find a subreddit", text: $viewModel.searchText)
            .autocorrectionDisabled()
          if !viewModel.searchText.isEmpty {
            Button {
              viewModel.searchText = ""
              viewModel.updateSearchQuery("")
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
          }
        }
      }

      Section("Feeds") {
        ForEach(viewModel.items) { item in
          Label(item.title, systemImage: item.icon)
            .tag(item)
            .contextMenu {
              if item.id != Source.frontPage.id {
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

      if viewModel.isSearching {
        Section {
          Text("Searching…")
            .foregroundStyle(.secondary)
        }
      }

      if !viewModel.recentSuggestions.isEmpty {
        Section("Recent") {
          ForEach(viewModel.recentSuggestions) { source in
            Button {
              viewModel.addAndSelectSubreddit(source)
              onSelect(source)
            } label: {
              Label(source.title, systemImage: "clock")
            }
          }

          Button("Clear Recent") {
            viewModel.clearAllRecents()
          }
          .font(.caption)
        }
      }

      if !viewModel.searchResults.isEmpty {
        Section("Reddit") {
          ForEach(viewModel.searchResults) { source in
            Button {
              viewModel.addAndSelectSubreddit(source)
              onSelect(source)
            } label: {
              Label(source.title, systemImage: source.icon)
            }
          }
        }
      }
    }
    .navigationTitle("Mana")
    .onChange(of: viewModel.searchText) { _, newValue in
      viewModel.updateSearchQuery(newValue)
    }
  }

  private var selectionBinding: Binding<Source?> {
    Binding(
      get: { viewModel.selectedItem },
      set: { selected in
        viewModel.select(selected)
        onSelect(selected)
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
