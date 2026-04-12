//
//  TransportContentColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

@MainActor
final class PostTransportViewModel {
  private(set) var after: String?

  func reset() {
    after = nil
  }

  func fetch(source: Source, sort: PostSort, timeRange: TimeRange) async throws -> [Post] {
    let result = try await TransportServices.fetchPosts(
      source: source,
      sort: sort,
      timeRange: timeRange,
      after: after
    )
    after = result.after
    return result.posts
  }
}
