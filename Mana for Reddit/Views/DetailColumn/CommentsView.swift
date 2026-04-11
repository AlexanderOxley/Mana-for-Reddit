//
//  CommentsView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct CommentsView: View {
    let post: Post
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.title3)
                        .bold()
                    Text("r/\(post.subreddit) · u/\(post.author)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        Label("\(post.score)", systemImage: "arrow.up")
                        Label("\(post.numComments)", systemImage: "bubble.right")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Comments") {
                if viewModel.isLoadingComments {
                    ProgressView("Loading comments…")
                        .frame(maxWidth: .infinity)
                } else if let error = viewModel.commentsErrorMessage {
                    Text(error)
                        .foregroundStyle(.secondary)
                } else if viewModel.comments.isEmpty {
                    Text("No comments yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.comments) { comment in
                        CommentRowView(comment: comment)
                            .onAppear {
                                if comment.id == viewModel.comments.last?.id {
                                    Task { @MainActor in
                                        await Task.yield()
                                        await viewModel.loadMoreComments(for: post)
                                    }
                                }
                            }
                    }
                    
                    if viewModel.isLoadingMoreComments {
                        HStack {
                            Spacer()
                            ProgressView("Loading more…")
                            Spacer()
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Comments")
        .safeAreaInset(edge: .top) {
            SortHeaderView(
                title: "Comments",
                options: CommentSort.allCases,
                label: { $0.title },
                selection: $viewModel.selectedCommentSort,
                showTimeRange: viewModel.selectedCommentSort.supportsTimeRange,
                timeRange: $viewModel.selectedCommentTimeRange
            )
        }
        .onChange(of: viewModel.selectedCommentSort) { _, _ in
            Task { @MainActor in
                await Task.yield()
                await viewModel.loadComments(for: post, force: true)
            }
        }
        .onChange(of: viewModel.selectedCommentTimeRange) { _, _ in
            guard viewModel.selectedCommentSort.supportsTimeRange else { return }
            Task { @MainActor in
                await Task.yield()
                await viewModel.loadComments(for: post, force: true)
            }
        }
        .task(id: post.id) {
            await viewModel.loadComments(for: post)
        }
    }
}



#Preview {
    let vm = AppViewModel()
    vm.comments = [
        Comment(
            id: "c1",
            author: "swifter99",
            body: "Great breakdown. This helped me understand structured concurrency a lot better.",
            score: 42,
            depth: 0,
            replies: []
        ),
        Comment(
            id: "c2",
            author: "alexo",
            body: "Same here. The actor examples were super clear.",
            score: 15,
            depth: 1,
            replies: []
        )
    ]
    return NavigationStack {
        CommentsView(post: Post(
            id: "1",
            title: "Swift concurrency deep dive — actors, tasks, and async/await explained",
            author: "swifter99",
            subreddit: "swift",
            score: 2048,
            numComments: 87,
            url: "https://example.com",
            thumbnail: nil,
            permalink: "/r/swift/comments/1"
        ))
    }
    .environmentObject(vm)
}
