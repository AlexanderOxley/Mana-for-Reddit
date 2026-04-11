//
//  ContentColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct ContentColumnView: View {
    let selectedFeed: SidebarItem
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        Group {
            if viewModel.isLoadingPosts && viewModel.posts.isEmpty {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.postsErrorMessage, viewModel.posts.isEmpty {
                ContentUnavailableView(
                    "Could not load posts",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else {
                List(selection: $viewModel.selectedPost) {
                    ForEach(viewModel.posts) { post in
                        PostRowView(post: post)
                            .tag(post)
                            .onAppear {
                                if post.id == viewModel.posts.last?.id {
                                    Task { @MainActor in
                                        await Task.yield()
                                        await viewModel.loadMoreFrontPage()
                                    }
                                }
                            }
                    }

                    if viewModel.isLoadingMorePosts {
                        HStack {
                            Spacer()
                            ProgressView("Loading more…")
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadFrontPage()
                }
            }
        }
        .navigationTitle(selectedFeed.rawValue)
        .safeAreaInset(edge: .top) {
            SortHeaderView(
                title: "Posts",
                options: PostSort.allCases,
                label: { $0.title },
                selection: $viewModel.selectedPostSort,
                showTimeRange: viewModel.selectedPostSort.supportsTimeRange,
                timeRange: $viewModel.selectedPostTimeRange
            )
        }
        .onChange(of: viewModel.selectedPostSort) { _, _ in
            Task { @MainActor in
                await Task.yield()
                await viewModel.loadFrontPage()
            }
        }
        .onChange(of: viewModel.selectedPostTimeRange) { _, _ in
            guard viewModel.selectedPostSort.supportsTimeRange else { return }
            Task { @MainActor in
                await Task.yield()
                await viewModel.loadFrontPage()
            }
        }
        .task {
            guard viewModel.posts.isEmpty else { return }
            await viewModel.loadFrontPage()
        }
    }
}

#Preview {
    let vm = AppViewModel()
    vm.posts = [
        Post(id: "1", title: "Swift concurrency deep dive", author: "swifter", subreddit: "swift", score: 1024, numComments: 55, url: "https://example.com", thumbnail: nil, permalink: "/r/swift/1"),
        Post(id: "2", title: "I built a Reddit client in SwiftUI", author: "alexo", subreddit: "iOSProgramming", score: 512, numComments: 33, url: "https://example.com", thumbnail: nil, permalink: "/r/iOSProgramming/2"),
    ]
    return NavigationStack {
        ContentColumnView(selectedFeed: .frontPage)
    }
    .environmentObject(vm)
}
