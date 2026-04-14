//
//  ContentColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct ContentColumnView: View {
    let selectedFeed: SidebarColumnItem
    @EnvironmentObject private var viewModel: AppViewModel

    private var column: ContentColumn {
        viewModel.contentColumn
    }

    var body: some View {
        Group {
            if column.isLoadingPosts && column.posts.isEmpty {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = column.postsErrorMessage, column.posts.isEmpty {
                ContentUnavailableView(
                    "Could not load posts",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else {
                List(selection: Binding(
                    get: { viewModel.selectedPost },
                    set: { viewModel.selectPost($0) }
                )) {
                    ForEach(column.posts) { post in
                        PostRowView(post: post)
                            .tag(post)
                            .onAppear {
                                if post.id == column.posts.last?.id {
                                    Task { @MainActor in
                                        await Task.yield()
                                        await viewModel.getPosts()
                                    }
                                }
                            }
                    }

                    if column.isLoadingMorePosts {
                        HStack {
                            Spacer()
                            ProgressView("Loading more…")
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.getPosts(refresh: true)
                }
            }
        }
        .navigationTitle(selectedFeed.title)
        .safeAreaInset(edge: .top) {
            SortHeaderView(
                title: "Posts",
                options: PostSort.allCases,
                label: { $0.title },
                selection: Binding(
                    get: { column.postSort },
                    set: { viewModel.updatePostSort($0) }
                ),
                showTimeRange: column.postSort.supportsTimeRange,
                timeRange: Binding(
                    get: { column.postTimeRange },
                    set: { viewModel.updatePostTimeRange($0) }
                )
            )
        }
        .onChange(of: column.postSort) { _, _ in
            Task { @MainActor in
                await Task.yield()
                await viewModel.getPosts(refresh: true)
            }
        }
        .onChange(of: column.postTimeRange) { _, _ in
            guard column.postSort.supportsTimeRange else { return }
            Task { @MainActor in
                await Task.yield()
                await viewModel.getPosts(refresh: true)
            }
        }
        .task {
            guard column.posts.isEmpty else { return }
            await viewModel.getPosts(refresh: true)
        }
    }
}

#Preview {
    let vm = AppViewModel()
    vm.contentColumn.posts = [
        Post(id: "1", title: "Swift concurrency deep dive", author: "swifter", subreddit: "swift", score: 1024, numComments: 55, url: "https://example.com", thumbnail: nil, permalink: "/r/swift/1"),
        Post(id: "2", title: "I built a Reddit client in SwiftUI", author: "alexo", subreddit: "iOSProgramming", score: 512, numComments: 33, url: "https://example.com", thumbnail: nil, permalink: "/r/iOSProgramming/2"),
    ]
    return NavigationStack {
        ContentColumnView(selectedFeed: .frontPage)
    }
    .environmentObject(vm)
}
