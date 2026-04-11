//
//  DetailColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailColumnView: View {
  let item: Post
  @EnvironmentObject private var detailViewModel: DetailColumnViewModel
  @EnvironmentObject private var contentViewModel: ContentColumnViewModel

  var body: some View {
    List(selection: $detailViewModel.selectedCommentID) {
      Section {
        DetailHeaderSectionView(item: item)
      }

      Section {
        DetailPostSectionView(item: item)
      }

      Section {
        DetailCommentsSectionView()
      }
    }
    .listStyle(.plain)
    .refreshable {
      await detailViewModel.refreshPostAndComments(using: contentViewModel, fallbackPost: item)
    }
    .keybinds([
      Keybind(.return, description: "Toggle collapse selected comment") {
        guard let id = detailViewModel.selectedCommentID else { return }
        detailViewModel.toggleCollapse(for: id)
      }
    ])
    .navigationTitle(detailViewModel.post?.title ?? item.title)
    .toolbar {
      #if os(macOS)
        ToolbarItemGroup(placement: .automatic) {
          Button {
            Task { @MainActor in
              await detailViewModel.refreshPostAndComments(
                using: contentViewModel, fallbackPost: item)
            }
          } label: {
            Label("Refresh Post and Comments", systemImage: "arrow.clockwise")
          }

          Menu {
            ForEach(CommentSort.allCases, id: \.self) { option in
              Button {
                detailViewModel.sort = option
              } label: {
                if option == detailViewModel.sort {
                  Label(option.title, systemImage: "checkmark")
                } else {
                  Text(option.title)
                }
              }
            }
          } label: {
            Text("Sort: \(detailViewModel.sort.title)")
          }

          if detailViewModel.sort.supportsTimeRange {
            Menu {
              ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                  detailViewModel.timeRange = range
                } label: {
                  if range == detailViewModel.timeRange {
                    Label(range.title, systemImage: "checkmark")
                  } else {
                    Text(range.title)
                  }
                }
              }
            } label: {
              Text("Time: \(detailViewModel.timeRange.title)")
            }
          }
        }
      #else
        ToolbarItemGroup(placement: .bottomBar) {
          Spacer()

          Menu {
            ForEach(CommentSort.allCases, id: \.self) { option in
              Button {
                detailViewModel.sort = option
              } label: {
                if option == detailViewModel.sort {
                  Label(option.title, systemImage: "checkmark")
                } else {
                  Text(option.title)
                }
              }
            }
          } label: {
            Text("Sort: \(detailViewModel.sort.title)")
          }

          if detailViewModel.sort.supportsTimeRange {
            Menu {
              ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                  detailViewModel.timeRange = range
                } label: {
                  if range == detailViewModel.timeRange {
                    Label(range.title, systemImage: "checkmark")
                  } else {
                    Text(range.title)
                  }
                }
              }
            } label: {
              Text("Time: \(detailViewModel.timeRange.title)")
            }
          }
        }
      #endif
    }
    .onChange(of: detailViewModel.sort) { _, _ in
      Task { @MainActor in
        await Task.yield()
        await detailViewModel.load(refresh: true)
      }
    }
    .onChange(of: detailViewModel.timeRange) { _, _ in
      guard detailViewModel.sort.supportsTimeRange else { return }
      Task { @MainActor in
        await Task.yield()
        await detailViewModel.load(refresh: true)
      }
    }
    .task(id: item.id) {
      detailViewModel.setPost(item)
      await detailViewModel.load(refresh: true)
    }
  }
}

private struct DetailColumnLivePreviewHost: View {
  @StateObject private var detailViewModel = DetailColumnViewModel()
  @StateObject private var contentViewModel = ContentColumnViewModel(source: .frontPage)
  @State private var previewPost: Post?

  var body: some View {
    NavigationStack {
      Group {
        if let previewPost {
          DetailColumnView(item: previewPost)
            .environmentObject(detailViewModel)
            .environmentObject(contentViewModel)
        } else if let error = contentViewModel.errorMessage {
          ContentUnavailableView(
            "Live preview failed",
            systemImage: "exclamationmark.triangle",
            description: Text(error)
          )
        } else {
          ProgressView("Loading live Reddit preview…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .task {
        await loadPreviewDataIfNeeded()
      }
    }
  }

  @MainActor
  private func loadPreviewDataIfNeeded() async {
    guard previewPost == nil else { return }
    await contentViewModel.load(refresh: true)
    guard let firstPost = contentViewModel.posts.first else { return }
    previewPost = firstPost
    detailViewModel.setPost(firstPost)
  }
}

#Preview("Live Reddit") {
  DetailColumnLivePreviewHost()
}

#Preview("Sample") {
  let detailViewModel = DetailColumnViewModel()
  let contentViewModel = ContentColumnViewModel(source: .frontPage)
  let samplePost = Post(
    id: "1",
    title: "Swift concurrency deep dive — actors, tasks, and async/await explained",
    author: "swifter99",
    subreddit: "swift",
    score: 2048,
    numComments: 87,
    url: "https://example.com",
    thumbnail: nil,
    permalink: "/r/swift/comments/1"
  )
  NavigationStack {
    DetailColumnView(item: samplePost)
      .environmentObject(detailViewModel)
      .environmentObject(contentViewModel)
  }
}
