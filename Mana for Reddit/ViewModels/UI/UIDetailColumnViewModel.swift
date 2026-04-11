//
//  UIDetailColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Combine
import Foundation

@MainActor
final class DetailColumnViewModel: ObservableObject {
  @Published var post: Post?
  @Published var sort: CommentSort = .best
  @Published var timeRange: TimeRange = .today

  @Published var comments: [Comment] = []
  @Published var selectedCommentID: String?
  @Published var collapsedCommentIDs: Set<String> = []
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var errorMessage: String?
  @Published var hasMore = true

  private var transport = CommentTransportViewModel()

  var visibleComments: [Comment] {
    var visible: [Comment] = []
    var collapsedDepthStack: [Int] = []

    for comment in comments {
      while let lastDepth = collapsedDepthStack.last, comment.depth <= lastDepth {
        collapsedDepthStack.removeLast()
      }

      if !collapsedDepthStack.isEmpty {
        continue
      }

      visible.append(comment)

      if collapsedCommentIDs.contains(comment.id) {
        collapsedDepthStack.append(comment.depth)
      }
    }

    return visible
  }

  func toggleCollapse(for commentID: String) {
    if collapsedCommentIDs.contains(commentID) {
      collapsedCommentIDs.remove(commentID)
    } else {
      collapsedCommentIDs.insert(commentID)
    }
  }

  func isCollapsed(_ commentID: String) -> Bool {
    collapsedCommentIDs.contains(commentID)
  }

  func setPost(_ post: Post?) {
    self.post = post
    reset()
  }

  func load(refresh: Bool = false) async {
    guard let post else { return }
    if refresh {
      guard !isLoading, !isLoadingMore else { return }
      reset()
    }

    let isInitialLoad = comments.isEmpty

    if isInitialLoad {
      guard !isLoading else { return }
      isLoading = true
    } else {
      guard hasMore, !isLoading, !isLoadingMore else { return }
      isLoadingMore = true
    }

    defer {
      isLoading = false
      isLoadingMore = false
    }

    do {
      let fetched = try await transport.fetch(
        permalink: post.permalink,
        sort: sort,
        timeRange: timeRange
      )

      if isInitialLoad {
        comments = fetched
      } else {
        let existingIDs = Set(comments.map(\.id))
        comments.append(contentsOf: fetched.filter { !existingIDs.contains($0.id) })
      }

      hasMore = transport.after != nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
      if isInitialLoad { hasMore = false }
    }
  }

  func refreshPostAndComments(
    using contentViewModel: ContentColumnViewModel,
    fallbackPost: Post
  ) async {
    let selectedPostID = post?.id ?? fallbackPost.id

    await contentViewModel.load(refresh: true)

    if let refreshedPost = contentViewModel.posts.first(where: { $0.id == selectedPostID }) {
      setPost(refreshedPost)
    } else {
      setPost(fallbackPost)
    }

    await load(refresh: true)
  }

  private func reset() {
    transport.reset()
    comments = []
    selectedCommentID = nil
    collapsedCommentIDs = []
    hasMore = true
    errorMessage = nil
  }
}
