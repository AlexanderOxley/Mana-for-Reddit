//
//  DetailHeaderSectionView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailHeaderSectionView: View {
  let item: Post

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      MarkdownTextView(markdown: item.title, font: .headline)
        .fixedSize(horizontal: false, vertical: true)
      PostBadgesView(post: item)
      PostAttributionView(post: item)
      PostEngagementView(post: item)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  List {
    Section {
      DetailHeaderSectionView(
        item: Post(
          id: "1",
          title: "Swift concurrency deep dive — actors, tasks, and async/await explained",
          author: "swifter99",
          subreddit: "swift",
          score: 2048,
          numComments: 87,
          url: "https://example.com",
          thumbnail: nil,
          permalink: "/r/swift/comments/1"
        ))
    }
  }
}
