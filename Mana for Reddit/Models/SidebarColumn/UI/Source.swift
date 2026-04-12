//
//  Source.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Source: Identifiable, Hashable, Sendable {
  let id: String
  let title: String
  let icon: String
  let listingPathPrefix: String

  nonisolated(unsafe) static let frontPage = Source(
    id: "front-page",
    title: "Front Page",
    icon: "house.fill",
    listingPathPrefix: ""
  )

  nonisolated(unsafe) static let defaults: [Source] = [.frontPage]

  static func subreddit(_ name: String) -> Source {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let cleaned = trimmed.hasPrefix("r/") ? String(trimmed.dropFirst(2)) : trimmed
    let normalized = cleaned.lowercased()
    return Source(
      id: "subreddit:\(normalized)",
      title: "r/\(normalized)",
      icon: "bubble.left.and.bubble.right.fill",
      listingPathPrefix: "/r/\(normalized)"
    )
  }
}
