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

  private var selectedCommentBinding: Binding<String?> {
    Binding(
      get: { viewModel.selectedCommentID },
      set: { selected in
        Task { @MainActor in
          await Task.yield()
          viewModel.selectComment(selected)
        }
      }
    )
  }

  var body: some View {
    List(selection: selectedCommentBinding) {
      Section {
        DetailHeaderSectionView(item: item)
      }

      Section("Post") {
        DetailPostSectionView(item: item)
      }

      Section("Comments") {
        DetailCommentsSectionView()
      }
    }
    .listStyle(.plain)
    .navigationTitle("Comments")
    .toolbar {
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
