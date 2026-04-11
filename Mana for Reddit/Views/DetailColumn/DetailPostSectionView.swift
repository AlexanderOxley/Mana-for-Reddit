//
//  DetailPostSectionView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailPostSectionView: View {
  let item: Post

  var body: some View {
    if !item.selfText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      Text(item.selfText)
        .textSelection(.enabled)
    } else if let postURL = URL(string: item.url) {
      Link(destination: postURL) {
        Label("Open linked content", systemImage: "link")
      }
    } else {
      Text("No post body available.")
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  List {
    Section("Post") {
      DetailPostSectionView(
        item: Post(
          id: "1",
          title: "Preview",
          author: "swifter99",
          subreddit: "swift",
          score: 2048,
          numComments: 87,
          url: "https://example.com",
          thumbnail: nil,
          permalink: "/r/swift/comments/1",
          selfText: "Long-form post body goes here so the detail pane can render readable content."
        ))
    }
  }
}
