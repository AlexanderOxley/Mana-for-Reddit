//
//  Entrypoint.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct Entrypoint: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarColumnView()
        } content: {
            if let selectedFeed = viewModel.selectedFeed {
                ContentColumnView(selectedFeed: selectedFeed)
            } else {
                ContentUnavailableView(
                    "Select a feed",
                    systemImage: "sidebar.left",
                    description: Text("Choose a source in the sidebar.")
                )
            }
        } detail: {
            if let selectedPost = viewModel.selectedPost {
                DetailColumnView(post: selectedPost)
            } else {
                ContentUnavailableView(
                    "Select a post",
                    systemImage: "text.bubble",
                    description: Text("Choose a post to read comments.")
                )
            }
        }
        .environmentObject(viewModel)
        .onChange(of: viewModel.selectedFeed) { _, _ in
            Task { @MainActor in
                await Task.yield()
                viewModel.selectedPost = nil
            }
        }
    }
}

#Preview {
    Entrypoint()
}
