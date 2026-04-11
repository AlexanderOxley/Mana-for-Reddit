//
//  DetailColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailColumnView: View {
    let post: Post
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        commentsView(for: post)
    }

    @ViewBuilder
    private func commentsView(for post: Post) -> some View {
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
                                    Task {
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
        .task(id: post.id) {
            await viewModel.loadComments(for: post)
        }
    }
}

#Preview {
    DetailColumnView(post: Post(
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
    .environmentObject(AppViewModel())
}
