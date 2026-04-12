//
//  PostEngagementView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct PostEngagementView: View {
  let post: Post

  var body: some View {
    HStack(spacing: 12) {
      Label("\(post.ups)", systemImage: "arrow.up")
      Label("\(post.numComments)", systemImage: "bubble.right")
    }
    .font(.caption)
    .foregroundStyle(.secondary)
  }
}

#Preview {
  PostEngagementView(
    post: Post(
      id: "1",
      title: "Preview",
      author: "swifter99",
      subreddit: "swift",
      ups: 2048,
      score: 2048,
      numComments: 87,
      url: "https://example.com",
      thumbnail: nil,
      permalink: "/r/swift/comments/1"
    )
  )
  .padding()
}
