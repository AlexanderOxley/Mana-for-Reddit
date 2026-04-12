//
//  PostAttributionView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct PostAttributionView: View {
  let post: Post
  var includeRelativeTime: Bool = true

  var body: some View {
    let domainPart = post.domain.isEmpty ? "" : " · \(post.domain)"
    let relativeCreatedPart = includeRelativeTime
      ? (post.relativeCreatedDescription.map { " · \($0)" } ?? "") : ""
    let editedPart = post.relativeEditedDescription.map { " · edited \($0)" } ?? ""

    Text(
      "\(post.subredditNamePrefixed) · u/\(post.author)"
        + domainPart
        + relativeCreatedPart
        + editedPart
    )
    .font(.caption)
    .foregroundStyle(.secondary)
  }
}

#Preview {
  PostAttributionView(
    post: Post(
      id: "1",
      title: "Preview",
      author: "swifter99",
      subreddit: "swift",
      score: 2048,
      numComments: 87,
      url: "https://example.com",
      thumbnail: nil,
      permalink: "/r/swift/comments/1",
      createdUTC: Date().addingTimeInterval(-3600).timeIntervalSince1970,
      domain: "example.com", subredditNamePrefixed: "r/swift", editedUTC: Date().addingTimeInterval(-1200).timeIntervalSince1970
    )
  )
  .padding()
}
