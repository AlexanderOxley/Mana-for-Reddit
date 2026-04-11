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
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var errorMessage: String?
  @Published var hasMore = true

  private var transport = CommentTransportViewModel()

  func setPost(_ post: Post?) {
    self.post = post
    reset()
  }

  func load(refresh: Bool = false) async {
    guard let post else { return }
    if refresh { reset() }

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

  private func reset() {
    transport.reset()
    comments = []
    hasMore = true
    errorMessage = nil
  }
}
