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
  @EnvironmentObject private var detailViewModel: DetailColumnViewModel

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

  var body: some View {
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
    .navigationTitle(selectedFeed.title)
    .safeAreaInset(edge: .top) {
      SortHeaderView(
        title: "Posts",
        options: PostSort.allCases,
        label: { $0.title },
        selection: $viewModel.sort,
        showTimeRange: viewModel.sort.supportsTimeRange,
        timeRange: $viewModel.timeRange
      )
    }
    .onChange(of: viewModel.sort) { _, _ in
      Task { @MainActor in
        await Task.yield()
        if let currentPost = detailViewModel.post {
          await detailViewModel.refreshPostAndComments(using: viewModel, fallbackPost: currentPost)
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
          await detailViewModel.refreshPostAndComments(using: viewModel, fallbackPost: currentPost)
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
  }
}

struct ContentColumnView_Previews: PreviewProvider {
  static var previews: some View {
    let contentViewModel = ContentColumnViewModel(source: .frontPage)
    contentViewModel.posts = [
      Post(id: "1", title: "Swift concurrency deep dive", author: "swifter", subreddit: "swift", score: 1024, numComments: 55, url: "https://example.com", thumbnail: nil, permalink: "/r/swift/1"),
      Post(id: "2", title: "I built a Reddit client in SwiftUI", author: "alexo", subreddit: "iOSProgramming", score: 512, numComments: 33, url: "https://example.com", thumbnail: nil, permalink: "/r/iOSProgramming/2"),
    ]
    let detailViewModel = DetailColumnViewModel()

    return NavigationStack {
      ContentColumnView(selectedFeed: .frontPage)
    }
    .environmentObject(contentViewModel)
    .environmentObject(detailViewModel)
  }
}
