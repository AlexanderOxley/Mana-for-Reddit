//
//  PostSupplementaryMetadataView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct PostSupplementaryMetadataView: View {
  let post: Post

  var body: some View {
    if !post.domain.isEmpty || post.relativeEditedDescription != nil {
      Text(
        [
          post.domain.isEmpty ? nil : post.domain,
          post.relativeEditedDescription.map { "edited \($0)" },
        ]
          .compactMap { $0 }
          .joined(separator: " · ")
      )
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  PostSupplementaryMetadataView(
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
      domain: "youtube.com",
      editedUTC: Date().addingTimeInterval(-600).timeIntervalSince1970
    )
  )
  .padding()
}
