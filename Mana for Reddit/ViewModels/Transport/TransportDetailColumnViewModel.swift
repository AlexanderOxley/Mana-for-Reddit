//
//  TransportDetailColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

@MainActor
final class CommentTransportViewModel {
  private(set) var after: String?

  func reset() {
    after = nil
  }

  func fetch(
    permalink: String,
    sort: CommentSort,
    timeRange: TimeRange
  ) async throws -> [Comment] {
    let result = try await TransportServices.fetchComments(
      permalink: permalink,
      sort: sort,
      timeRange: timeRange,
      after: after
    )
    after = result.after
    return flattenComments(result.comments)
  }

  func refreshThread(
    permalink: String,
    sort: CommentSort,
    timeRange: TimeRange
  ) async throws -> (post: Post?, comments: [Comment]) {
    reset()

    let result = try await TransportServices.fetchPostAndComments(
      permalink: permalink,
      sort: sort,
      timeRange: timeRange,
      after: nil
    )

    after = result.after
    return (result.post, flattenComments(result.comments))
  }

  private func flattenComments(_ roots: [Comment]) -> [Comment] {
    var result: [Comment] = []

    func walk(_ comment: Comment) {
      result.append(comment)
      for reply in comment.replies {
        walk(reply)
      }
    }

    for root in roots {
      walk(root)
    }

    return result
  }
}
