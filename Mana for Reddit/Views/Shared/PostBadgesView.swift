//
//  PostBadgesView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct PostBadgesView: View {
  let post: Post

  var body: some View {
    HStack(spacing: 8) {
      if post.isPinnedOrStickied {
        Label("Pinned", systemImage: "pin.fill")
          .font(.caption2)
          .foregroundStyle(.blue)
      }
      if !post.flairSegments.isEmpty {
        HStack(spacing: 4) {
          ForEach(Array(post.flairSegments.enumerated()), id: \.offset) { _, segment in
            switch segment {
            case .text(let value):
              Text(value)
                .font(.caption2)
            case .emoji(let url, let fallback):
              AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                  image
                    .resizable()
                    .scaledToFit()
                case .failure:
                  Text(fallback.isEmpty ? "🙂" : fallback)
                    .font(.caption2)
                case .empty:
                  ProgressView()
                @unknown default:
                  Text(fallback.isEmpty ? "🙂" : fallback)
                    .font(.caption2)
                }
              }
              .frame(width: 14, height: 14)
            }
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.quaternary, in: Capsule())
      }
      if post.over18 {
        Text("NSFW")
          .font(.caption2)
          .fontWeight(.semibold)
          .foregroundStyle(.red)
      }
      if post.spoiler {
        Text("Spoiler")
          .font(.caption2)
          .foregroundStyle(.orange)
      }
    }
  }
}

#Preview {
  PostBadgesView(
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
      over18: true, spoiler: true, linkFlairText: "Discussion", isStickied: true
    )
  )
  .padding()
}
