//
//  ContentColumn.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct ContentColumn {
  var source: Source
  var postSort: PostSort = .best
  var postTimeRange: TimeRange = .today

  var posts: [Post] = []
  var isLoadingPosts = false
  var postsErrorMessage: String?
  var isLoadingMorePosts = false
  var hasMorePosts = true

  private var postsAfter: String?

  // This init is for app state bootstrapping with an initial source.
  init(source: Source = .frontPage) {
    self.source = source
  }

  mutating func selectSource(_ source: Source) {
    self.source = source
    resetPosts()
  }

  mutating func resetPosts() {
    postsAfter = nil
    hasMorePosts = true
    posts = []
    postsErrorMessage = nil
  }

  mutating func getPosts(refresh: Bool = false) async {
    if refresh {
      resetPosts()
    }

    let isInitialLoad = posts.isEmpty

    if isInitialLoad {
      guard !isLoadingPosts else { return }
      isLoadingPosts = true
    } else {
      guard hasMorePosts, !isLoadingPosts, !isLoadingMorePosts else { return }
      guard postsAfter != nil else {
        hasMorePosts = false
        return
      }
      isLoadingMorePosts = true
    }

    defer {
      isLoadingPosts = false
      isLoadingMorePosts = false
    }

    do {
      let result = try await TransportServices.fetchPosts(
        sort: postSort,
        timeRange: postTimeRange,
        after: isInitialLoad ? nil : postsAfter
      )

      if isInitialLoad {
        posts = result.posts
      } else {
        let existingIDs = Set(posts.map(\.id))
        let uniqueNewPosts = result.posts.filter { !existingIDs.contains($0.id) }
        posts.append(contentsOf: uniqueNewPosts)
      }

      postsAfter = result.after
      hasMorePosts = result.after != nil
      postsErrorMessage = nil
    } catch {
      postsErrorMessage = error.localizedDescription
      if isInitialLoad {
        hasMorePosts = false
      }
    }
  }
}
