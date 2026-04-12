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
      if let thumbnail = post.thumbnail,
        thumbnail.hasPrefix("http")
      {
        let normalizedThumbnail = thumbnail.replacingOccurrences(of: "&amp;", with: "&")
        if let url = URL(string: normalizedThumbnail) {
          AsyncImage(url: url) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.secondary.opacity(0.15))
          }
          .frame(width: 70, height: 70)
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }

      VStack(alignment: .leading, spacing: 5) {
        Text(markdownTitle)
          .font(.headline)
          .lineLimit(3)
          .foregroundStyle(.primary)
          .tint(.blue)
        PostBadgesView(post: post)
        PostAttributionView(post: post)
        PostEngagementView(post: post)
      }
    }
    .padding(.vertical, 4)
  }

  private var markdownTitle: AttributedString {
    let value = post.title
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&lt;", with: "<")
      .replacingOccurrences(of: "&gt;", with: ">")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#39;", with: "'")

    if let parsed = try? AttributedString(
      markdown: value,
      options: AttributedString.MarkdownParsingOptions(
        interpretedSyntax: .inlineOnlyPreservingWhitespace)
    ) {
      return parsed
    }

    return AttributedString(value)
  }
}

#Preview("Normal") {
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

#Preview("NSFW") {
  PostRowView(
    post: Post(
      id: "nsfw123",
      title: "Late-night design thread with some spicy UI takes",
      author: "nightowl",
      subreddit: "design",
      score: 842,
      numComments: 91,
      url: "https://example.com/nsfw",
      thumbnail: nil,
      permalink: "/r/design/comments/nsfw123",
      over18: true
    )
  )
  .padding()
}

#Preview("Spoiler") {
  PostRowView(
    post: Post(
      id: "spoiler123",
      title: "Season finale discussion thread",
      author: "plotTwist",
      subreddit: "television",
      score: 1204,
      numComments: 388,
      url: "https://example.com/spoiler",
      thumbnail: nil,
      permalink: "/r/television/comments/spoiler123",
      spoiler: true
    )
  )
  .padding()
}

#Preview("Pinned") {
  PostRowView(
    post: Post(
      id: "pinned123",
      title: "Weekly discussion thread",
      author: "mod_team",
      subreddit: "swift",
      score: 0,
      numComments: 64,
      url: "https://example.com/pinned",
      thumbnail: nil,
      permalink: "/r/swift/comments/pinned123",
      isStickied: true
    )
  )
  .padding()
}

#Preview("NSFW + Spoiler") {
  PostRowView(
    post: Post(
      id: "both123",
      title: "Plot details from the unreleased director's cut",
      author: "cinephile",
      subreddit: "movies",
      score: 2142,
      numComments: 512,
      url: "https://example.com/both",
      thumbnail: nil,
      permalink: "/r/movies/comments/both123",
      over18: true,
      spoiler: true
    )
  )
  .padding()
}

#Preview("Flair + All Badges") {
  PostRowView(
    post: Post(
      id: "all123",
      title:
        "[Release] Mana for Reddit now supports video, galleries, markdown links, and a much denser content row layout",
      author: "manaapp",
      subreddit: "SwiftUI",
      score: 4096,
      numComments: 137,
      url: "https://example.com/release",
      thumbnail: "https://picsum.photos/140",
      permalink: "/r/SwiftUI/comments/all123",
      createdUTC: Date().addingTimeInterval(-7200).timeIntervalSince1970, over18: true,
      spoiler: true,
      linkFlairText: "Release",
      subredditNamePrefixed: "r/SwiftUI"
    )
  )
  .padding()
}
