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
  @State private var isShowingInspector = false

  private enum Column: Hashable { case sidebar, content, detail }
  @FocusState private var focusedColumn: Column?

  var body: some View {
    NavigationSplitView {
      SidebarColumnView { source in
        sidebarViewModel.select(source)
        detailViewModel.setPost(nil)
        guard let source else { return }
        contentViewModel.setSource(source)
      }
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button {
            isShowingInspector.toggle()
          } label: {
            Label("Settings", systemImage: "gearshape")
          }
        }
      }
      .focused($focusedColumn, equals: .sidebar)
      .onKeyPress(.rightArrow) {
        focusedColumn = .content
        return .handled
      }

    } content: {
      Group {
        if let selectedFeed = sidebarViewModel.selectedItem {
          ContentColumnView(selectedFeed: selectedFeed)
        } else {
          ContentUnavailableView(
            "Select a feed",
            systemImage: "sidebar.left",
            description: Text("Choose a source in the sidebar.")
          )
        }
      }
      .focused($focusedColumn, equals: .content)
      .onKeyPress(.leftArrow) {
        focusedColumn = .sidebar
        return .handled
      }
      .onKeyPress(.rightArrow) {
        focusedColumn = .detail
        return .handled
      }

    } detail: {
      Group {
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
      .focused($focusedColumn, equals: .detail)
      .onKeyPress(.leftArrow) {
        focusedColumn = .content
        return .handled
      }
      .onKeyPress(.return) {
        collapseSelectedComment()
        return .handled
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: AppCommand.focusSidebar)) { _ in
      focusedColumn = .sidebar
    }
    .onReceive(NotificationCenter.default.publisher(for: AppCommand.focusFeed)) { _ in
      focusedColumn = .content
    }
    .onReceive(NotificationCenter.default.publisher(for: AppCommand.focusPost)) { _ in
      focusedColumn = .detail
    }
    .onReceive(NotificationCenter.default.publisher(for: AppCommand.collapseSelectedComment)) { _ in
      collapseSelectedComment()
    }
    .environmentObject(sidebarViewModel)
    .environmentObject(contentViewModel)
    .environmentObject(detailViewModel)
    .inspector(isPresented: $isShowingInspector) {
      InspectorSettingsView(isShowingInspector: $isShowingInspector)
        .frame(minWidth: 280)
    }

  }

  private func collapseSelectedComment() {
    guard let selectedCommentID = detailViewModel.selectedCommentID else { return }
    detailViewModel.toggleCollapse(for: selectedCommentID)
  }
}

#Preview {
  Entrypoint()
}
