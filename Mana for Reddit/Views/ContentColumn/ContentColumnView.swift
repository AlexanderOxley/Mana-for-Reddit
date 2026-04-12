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
  @State private var selectedPost: Post?

  var body: some View {
    Group {
      if viewModel.isLoading && viewModel.displayedPosts.isEmpty {
        ProgressView("Loading…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let error = viewModel.errorMessage, viewModel.displayedPosts.isEmpty {
        ContentUnavailableView(
          "Could not load posts",
          systemImage: "exclamationmark.triangle",
          description: Text(error)
        )
      } else {
        List(selection: $selectedPost) {
          Section {
            SearchBarRow(prompt: "Search posts", text: $viewModel.searchText)
          }

          ForEach(viewModel.displayedPosts) { post in
            PostRowView(post: post)
              .tag(post)
              .onAppear {
                if !viewModel.isSearchActive, post.id == viewModel.posts.last?.id {
                  Task { @MainActor in
                    await Task.yield()
                    await viewModel.load()
                  }
                }
              }
          }

          if viewModel.isLoadingMore {
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
    .toolbar {
      #if os(macOS)
        ToolbarItemGroup(placement: .automatic) {
          Button {
            Task { @MainActor in
              await viewModel.load(refresh: true)
            }
          } label: {
            Label("Refresh Posts", systemImage: "arrow.clockwise")
          }

          Menu {
            ForEach(PostSort.allCases, id: \.self) { option in
              Button {
                viewModel.sort = option
              } label: {
                if option == viewModel.sort {
                  Label(option.title, systemImage: "checkmark")
                } else {
                  Text(option.title)
                }
              }
            }
          } label: {
            Text("Sort: \(viewModel.sort.title)")
          }

          if viewModel.sort.supportsTimeRange {
            Menu {
              ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                  viewModel.timeRange = range
                } label: {
                  if range == viewModel.timeRange {
                    Label(range.title, systemImage: "checkmark")
                  } else {
                    Text(range.title)
                  }
                }
              }
            } label: {
              Text("Time: \(viewModel.timeRange.title)")
            }
          }
        }
      #else
        ToolbarItemGroup(placement: .bottomBar) {
          Spacer()

          Menu {
            ForEach(PostSort.allCases, id: \.self) { option in
              Button {
                viewModel.sort = option
              } label: {
                if option == viewModel.sort {
                  Label(option.title, systemImage: "checkmark")
                } else {
                  Text(option.title)
                }
              }
            }
          } label: {
            Text("Sort: \(viewModel.sort.title)")
          }

          if viewModel.sort.supportsTimeRange {
            Menu {
              ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                  viewModel.timeRange = range
                } label: {
                  if range == viewModel.timeRange {
                    Label(range.title, systemImage: "checkmark")
                  } else {
                    Text(range.title)
                  }
                }
              }
            } label: {
              Text("Time: \(viewModel.timeRange.title)")
            }
          }
        }
      #endif
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
    .onChange(of: selectedPost) { _, post in
      Task { @MainActor in
        await Task.yield()
        detailViewModel.setPost(post)
      }
    }
    .onAppear {
      selectedPost = detailViewModel.post
    }
    .onChange(of: viewModel.searchText) { _, newValue in
      viewModel.updateSearchQuery(newValue)
    }
    .task(id: selectedFeed.id) {
      guard viewModel.posts.isEmpty else { return }
      await viewModel.load(refresh: true)
    }
  }
}

#Preview {
  let contentVM: ContentColumnViewModel = {
    let vm = ContentColumnViewModel(source: .frontPage)
    vm.posts = [
      Post(
        id: "1", title: "Swift concurrency deep dive", author: "swifter", subreddit: "swift",
        score: 1024, numComments: 55, url: "https://example.com", thumbnail: nil,
        permalink: "/r/swift/1"),
      Post(
        id: "2", title: "I built a Reddit client in SwiftUI", author: "alexo",
        subreddit: "iOSProgramming", score: 512, numComments: 33, url: "https://example.com",
        thumbnail: nil, permalink: "/r/iOSProgramming/2"),
    ]
    return vm
  }()
  let detailVM = DetailColumnViewModel()
  NavigationStack {
    ContentColumnView(selectedFeed: .frontPage)
  }
  .environmentObject(contentVM)
  .environmentObject(detailVM)
}
