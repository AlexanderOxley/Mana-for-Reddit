//
//  CommentsView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct CommentsView: View {
  let item: Post
  @EnvironmentObject private var viewModel: DetailColumnViewModel

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(item.title)
            .font(.title3)
            .bold()
          Text("r/\(item.subreddit) · u/\(item.author)")
            .font(.caption)
            .foregroundStyle(.secondary)
          HStack(spacing: 12) {
            Label("\(item.score)", systemImage: "arrow.up")
            Label("\(item.numComments)", systemImage: "bubble.right")
          }
          .font(.caption)
          .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
      }

      Section("Post") {
        if !item.selfText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          Text(item.selfText)
            .textSelection(.enabled)
        } else if let postURL = URL(string: item.url) {
          Link(destination: postURL) {
            Label("Open linked content", systemImage: "link")
          }
        } else {
          Text("No post body available.")
            .foregroundStyle(.secondary)
        }
      }

      Section("Comments") {
        if viewModel.isLoading {
          ProgressView("Loading comments…")
            .frame(maxWidth: .infinity)
        } else if let error = viewModel.errorMessage {
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
      }
    }
    .listStyle(.plain)
    .navigationTitle("Comments")
    .toolbar {
      ToolbarItemGroup(placement: .automatic) {
        Menu {
          ForEach(CommentSort.allCases, id: \.self) { option in
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
        .disabled(!viewModel.sort.supportsTimeRange)
      }
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
    .task(id: item.id) {
      await viewModel.load(refresh: true)
    }
  }
}

#Preview {
  let vm: DetailColumnViewModel = {
    let vm = DetailColumnViewModel()
    vm.setPost(
      Post(
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
      ))
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
      ),
    ]
    return vm
  }()
  NavigationStack {
    if let detailItem = vm.post {
      CommentsView(item: detailItem)
    }
  }
  .environmentObject(vm)
}
