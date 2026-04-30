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
  private var loadTask: Task<[Comment], Error>?
  private var loadTaskID: UUID?

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
    ensureValidSelection()
  }

  func selectComment(_ commentID: String?) {
    selectedCommentID = commentID
  }

  func isCollapsed(_ commentID: String) -> Bool {
    collapsedCommentIDs.contains(commentID)
  }

  func setPost(_ post: Post?) {
    guard self.post?.id != post?.id else { return }
    cancelLoad()
    self.post = post
    reset()
  }

  func load(refresh: Bool = false) async {
    guard let post else { return }
    if refresh {
      cancelLoad()
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

    let loadID = UUID()
    loadTaskID = loadID

    defer {
      if loadTaskID == loadID {
        loadTask = nil
        loadTaskID = nil
        isLoading = false
        isLoadingMore = false
      }
    }

    do {
      let permalink = post.permalink
      let sort = sort
      let timeRange = timeRange
      let loadTask = Task { [transport] in
        try await transport.fetch(
          permalink: permalink,
          sort: sort,
          timeRange: timeRange
        )
      }
      self.loadTask = loadTask

      let fetched = try await loadTask.value
      guard !Task.isCancelled else { return }

      if isInitialLoad {
        comments = fetched
      } else {
        let existingIDs = Set(comments.map(\.id))
        comments.append(contentsOf: fetched.filter { !existingIDs.contains($0.id) })
      }

      ensureValidSelection()
      hasMore = transport.after != nil
      errorMessage = nil
    } catch is CancellationError {
      return
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

  func reloadCurrentPostAndComments(fallbackPost: Post) async {
    let currentPost = post ?? fallbackPost

    cancelLoad()
    reset()
    isLoading = true

    defer {
      isLoading = false
      isLoadingMore = false
    }

    do {
      let refreshedThread = try await transport.refreshThread(
        permalink: currentPost.permalink,
        sort: sort,
        timeRange: timeRange
      )

      if let refreshedPost = refreshedThread.post {
        post = refreshedPost
      } else {
        post = currentPost
      }

      comments = refreshedThread.comments
      hasMore = transport.after != nil
      errorMessage = nil
      ensureValidSelection()
    } catch is CancellationError {
      post = currentPost
    } catch {
      post = currentPost
      errorMessage = error.localizedDescription
      hasMore = false
    }
  }

  private func ensureValidSelection() {
    let visibleIDs = Set(visibleComments.map(\.id))

    if let selectedCommentID, visibleIDs.contains(selectedCommentID) {
      return
    }

    selectedCommentID = visibleComments.first?.id
  }

  private func cancelLoad() {
    loadTask?.cancel()
    loadTask = nil
    loadTaskID = nil
    isLoading = false
    isLoadingMore = false
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
