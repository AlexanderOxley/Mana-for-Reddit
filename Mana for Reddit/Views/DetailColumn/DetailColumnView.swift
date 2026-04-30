//
//  DetailColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailColumnView: View {
  let item: Post
  @EnvironmentObject private var viewModel: DetailColumnViewModel
  @Environment(\.openURL) private var openURL

  private var currentPost: Post {
    viewModel.post ?? item
  }

  private var shareURL: URL? {
    URL(string: "https://www.reddit.com\(currentPost.permalink)")
  }

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 16) {
        DetailHeaderSectionView(item: currentPost)
        DetailPostSectionView(item: currentPost)
        DetailCommentsSectionView()
      }
      .padding(.horizontal)
      .padding(.vertical, 12)
    }
    #if os(iOS)
      .refreshable {
        await viewModel.reloadCurrentPostAndComments(fallbackPost: item)
      }
    #endif
    .toolbar {
      if let shareURL {
        ToolbarItem(placement: .primaryAction) {
          Menu {
            ShareLink(item: shareURL) {
              Label("Share post", systemImage: "square.and.arrow.up")
            }

            Button {
              openURL(shareURL)
            } label: {
              Label("Open in Safari", systemImage: "safari")
            }
          } label: {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          .accessibilityLabel("Share and open options")
        }
      }

      ToolbarItem(placement: .primaryAction) {
        Button {
          reloadPostAndComments()
        } label: {
          Label("Reload post and comments", systemImage: "arrow.clockwise")
        }
        .accessibilityLabel("Reload post and comments")
      }

      SortToolbarContent(
        title: "Comments",
        options: CommentSort.allCases,
        label: { $0.title },
        selection: $viewModel.sort,
        showTimeRange: viewModel.sort.supportsTimeRange,
        timeRange: $viewModel.timeRange
      )
    }
    .task(id: item.id) {
      if viewModel.post?.id != item.id {
        viewModel.setPost(item)
      }
      await viewModel.load(refresh: true)
    }
    .onChange(of: viewModel.sort) { _, _ in
      Task { @MainActor in
        await Task.yield()
        await viewModel.load(refresh: true)
      }
    }
    .onChange(of: viewModel.timeRange) { _, _ in
      guard viewModel.sort.supportsTimeRange else { return }
      Task { @MainActor in
        await Task.yield()
        await viewModel.load(refresh: true)
      }
    }
  }

  private func reloadPostAndComments() {
    Task { @MainActor in
      await Task.yield()
      await viewModel.reloadCurrentPostAndComments(fallbackPost: item)
    }
  }
}

private struct DetailColumnPreviewHost: View {
  @StateObject private var contentViewModel = ContentColumnViewModel(source: .frontPage)
  @StateObject private var detailViewModel = DetailColumnViewModel()

  private let previewItem = Post(
    id: "1",
    title: "Swift concurrency deep dive — actors, tasks, and async/await explained",
    author: "swifter99",
    subreddit: "swift",
    score: 2048,
    numComments: 87,
    url: "https://example.com",
    thumbnail: nil,
    permalink: "/r/swift/comments/1",
    selfText: "Long-form post body goes here so the detail pane can render readable content."
  )

  var body: some View {
    NavigationStack {
      DetailColumnView(item: previewItem)
    }
    .environmentObject(contentViewModel)
    .environmentObject(detailViewModel)
    .task {
      if detailViewModel.post?.id != previewItem.id {
        detailViewModel.setPost(previewItem)
      }
    }
  }
}

#Preview {
  DetailColumnPreviewHost()
}
