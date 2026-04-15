//
//  ContentColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct ContentColumnView: View {
  let selectedFeed: Source
  @EnvironmentObject private var viewModel: ContentColumnViewModel
  @EnvironmentObject private var sidebarViewModel: SidebarColumnViewModel
  @EnvironmentObject private var detailViewModel: DetailColumnViewModel
  @EnvironmentObject private var switcherViewModel: ContentSubredditSwitcherViewModel

  var body: some View {
    contentBody
      .navigationTitle("")
      .toolbar {
        ToolbarItem(placement: .principal) {
          SubredditSwitcherButtonView(title: selectedFeed.title) {
            switcherViewModel.present()
          }
        }

        SortToolbarContent(
          title: "Posts",
          options: PostSort.allCases,
          label: { $0.title },
          selection: $viewModel.sort,
          showTimeRange: viewModel.sort.supportsTimeRange,
          timeRange: $viewModel.timeRange
        )
      }
      .onReceive(NotificationCenter.default.publisher(for: AppCommand.openSubredditSwitcher)) { _ in
        switcherViewModel.present()
      }
      #if os(macOS)
        .keybinds([
          Keybind("f", modifiers: [.command], description: "Open subreddit switcher") {
            switcherViewModel.present()
          }
        ])
      #endif
      .onChange(of: viewModel.sort) { _, _ in
        Task { @MainActor in
          await Task.yield()
          if let currentPost = detailViewModel.post {
            await detailViewModel.refreshPostAndComments(
              using: viewModel, fallbackPost: currentPost)
          } else {
            await viewModel.load(refresh: true)
          }
        }
      }
      .onChange(of: viewModel.timeRange) { _, _ in
        guard viewModel.sort.supportsTimeRange else { return }
        Task { @MainActor in
          await Task.yield()
          if let currentPost = detailViewModel.post {
            await detailViewModel.refreshPostAndComments(
              using: viewModel, fallbackPost: currentPost)
          } else {
            await viewModel.load(refresh: true)
          }
        }
      }
      .task(id: selectedFeed.id) {
        if viewModel.source.id != selectedFeed.id {
          viewModel.setSource(selectedFeed)
        }
        guard viewModel.posts.isEmpty else { return }
        await viewModel.load(refresh: true)
      }
      .onChange(of: selectedFeed.id) { _, _ in
        switcherViewModel.dismiss()
        switcherViewModel.clearQuery()
      }
  }

  @ViewBuilder
  private var contentBody: some View {
    let displayedPosts = viewModel.displayedPosts

    Group {
      if viewModel.isLoading && displayedPosts.isEmpty {
        ProgressView("Loading…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = viewModel.errorMessage, displayedPosts.isEmpty {
        ContentUnavailableView(
          "Could not load posts",
          systemImage: "exclamationmark.triangle",
          description: Text(error)
        )
      } else {
        List(selection: selectedPostBinding) {
          ForEach(displayedPosts) { post in
            PostRowView(post: post)
              .tag(post)
              .onAppear {
                guard !viewModel.isSearchActive else { return }
                if post.id == displayedPosts.last?.id {
                  Task { @MainActor in
                    await Task.yield()
                    await viewModel.load()
                  }
                }
              }
          }

          if viewModel.isLoadingMore && !viewModel.isSearchActive {
            HStack {
              Spacer()
              ProgressView("Loading more…")
              Spacer()
            }
          }
        }
        .listStyle(.plain)
        .refreshable {
          await viewModel.load(refresh: true)
        }
      }
    }
  }

  private var selectedPostBinding: Binding<Post?> {
    Binding(
      get: { detailViewModel.post },
      set: { selected in
        Task { @MainActor in
          await Task.yield()
          detailViewModel.setPost(selected)
        }
      }
    )
  }

}

#Preview {
  let contentViewModel: ContentColumnViewModel = {
    let viewModel = ContentColumnViewModel(source: .frontPage)
    viewModel.posts = [
      Post(
        id: "1", title: "Swift concurrency deep dive", author: "swifter", subreddit: "swift",
        score: 1024, numComments: 55, url: "https://example.com", thumbnail: nil,
        permalink: "/r/swift/1"),
      Post(
        id: "2", title: "I built a Reddit client in SwiftUI", author: "alexo",
        subreddit: "iOSProgramming", score: 512, numComments: 33, url: "https://example.com",
        thumbnail: nil, permalink: "/r/iOSProgramming/2"),
    ]
    return viewModel
  }()
  let sidebarViewModel = SidebarColumnViewModel()
  let detailViewModel: DetailColumnViewModel = DetailColumnViewModel()

  return NavigationStack {
    ContentColumnView(selectedFeed: .frontPage)
  }
  .environmentObject(sidebarViewModel)
  .environmentObject(contentViewModel)
  .environmentObject(detailViewModel)
  .environmentObject(ContentSubredditSwitcherViewModel())
}
