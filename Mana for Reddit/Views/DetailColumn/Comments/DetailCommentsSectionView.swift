//
//  DetailCommentsSectionView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailCommentsSectionView: View {
  @Binding var searchText: String
  @EnvironmentObject private var viewModel: DetailColumnViewModel

  var body: some View {
    let visibleComments =
      searchText.isEmpty
      ? viewModel.visibleComments
      : viewModel.comments.filter {
        $0.author.localizedCaseInsensitiveContains(searchText)
          || $0.body.localizedCaseInsensitiveContains(searchText)
      }

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
      SearchBarRow(prompt: "Search comments", text: $searchText)
      ForEach(visibleComments) { comment in
        CommentRowView(
          comment: comment,
          isCollapsed: viewModel.isCollapsed(comment.id),
          onToggleCollapse: { viewModel.toggleCollapse(for: comment.id) }
        )
        .id("\(comment.id)-\(viewModel.isCollapsed(comment.id))")
        .onAppear {
          if comment.id == viewModel.visibleComments.last?.id {
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

#Preview {
  let vm: DetailColumnViewModel = {
    let vm = DetailColumnViewModel()
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

  List {
    Section("Comments") {
      DetailCommentsSectionView(searchText: .constant(""))
    }
  }
  .environmentObject(vm)
}
