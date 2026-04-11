//
//  DetailColumn.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct DetailColumn {
  var item: Post?
  var commentSort: CommentSort = .best
  var commentTimeRange: TimeRange = .today

  var comments: [Comment] = []
  var isLoadingComments = false
  var commentsErrorMessage: String?
  var isLoadingMoreComments = false
  var hasMoreComments = true

  private var commentsAfter: String?

  // This init supports restoring detail state from a pre-selected post.
  init(item: Post? = nil) {
    self.item = item
  }

  mutating func selectItem(_ item: Post?) {
    self.item = item
    resetComments()
  }

  mutating func resetComments() {
    commentsAfter = nil
    hasMoreComments = true
    comments = []
    commentsErrorMessage = nil
  }

  mutating func getComments(refresh: Bool = false) async {
    guard let item else { return }

    if refresh {
      resetComments()
    }

    let isInitialLoad = comments.isEmpty

    if isInitialLoad {
      guard !isLoadingComments else { return }
      isLoadingComments = true
    } else {
      guard hasMoreComments, !isLoadingComments, !isLoadingMoreComments else { return }
      guard commentsAfter != nil else {
        hasMoreComments = false
        return
      }
      isLoadingMoreComments = true
    }

    defer {
      isLoadingComments = false
      isLoadingMoreComments = false
    }

    do {
      let result = try await TransportServices.fetchComments(
        permalink: item.permalink,
        sort: commentSort,
        timeRange: commentTimeRange,
        after: isInitialLoad ? nil : commentsAfter
      )

      let flattenedIncoming = flattenComments(result.comments)

      if isInitialLoad {
        comments = flattenedIncoming
      } else {
        let existingIDs = Set(comments.map(\.id))
        let uniqueNewComments = flattenedIncoming.filter { !existingIDs.contains($0.id) }
        comments.append(contentsOf: uniqueNewComments)
      }

      commentsAfter = result.after
      hasMoreComments = result.after != nil
      commentsErrorMessage = nil
    } catch {
      commentsErrorMessage = error.localizedDescription
      if isInitialLoad {
        hasMoreComments = false
      }
    }
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
