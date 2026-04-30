//
//  PostRowView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct PostRowView: View {
  let post: Post

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      if let url = post.thumbnailURL {
        AsyncImage(url: url) { phase in
          switch phase {
          case .empty:
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondary.opacity(0.15))
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
          case .failure:
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondary.opacity(0.12))
              .overlay {
                Image(systemName: "photo")
                  .foregroundStyle(.secondary)
              }
          @unknown default:
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondary.opacity(0.15))
          }
        }
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }

      VStack(alignment: .leading, spacing: 5) {
        Text(post.title)
          .font(.headline)
          .lineLimit(3)

        Text("r/\(post.subreddit) · u/\(post.author)")
          .font(.caption)
          .foregroundStyle(.secondary)

        if !post.domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          Text(post.domain)
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }

        if !post.flairSegments.isEmpty {
          PostBadgesView(post: post)
        }

        HStack(spacing: 12) {
          Label("\(post.score)", systemImage: "arrow.up")
          Label("\(post.numComments)", systemImage: "bubble.right")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  PostRowView(
    post: Post(
      id: "abc123",
      title:
        "SwiftUI is amazing — here is a really long title to test how multi-line wrapping looks in the row",
      author: "alexo",
      subreddit: "swift",
      score: 1337,
      numComments: 42,
      url: "https://example.com",
      thumbnail: nil,
      permalink: "/r/swift/comments/abc123"
    )
  )
  .padding()
}
