//
//  DetailPostSectionView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailPostSectionView: View {
  let item: Post

  private var trimmedSelfText: String? {
    let t = item.selfText.trimmingCharacters(in: .whitespacesAndNewlines)
    return t.isEmpty ? nil : t
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      switch item.contentIntent {
      case .gallery(let imageURLs):
        DetailPostGalleryView(imageURLs: imageURLs)
      case .video(let videoURL):
        DetailPostVideoView(videoURL: videoURL)
      case .image(let imageURL):
        DetailPostImageView(imageURL: imageURL)
      case .thirdParty(let embed):
        ThirdPartyEmbedContainerView(embed: embed)
      case .externalLink(let externalURL):
        DetailExternalLinkButton(externalURL: externalURL)
      case .none:
        if trimmedSelfText == nil {
          Text("No post body available.")
            .foregroundStyle(.secondary)
        }
      }

      if let selfText = trimmedSelfText {
        MarkdownTextView(markdown: selfText, font: .body)
      }
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
          url: "https://i.redd.it/q8l3d9u2xmya1.jpg",
          thumbnail: nil,
          permalink: "/r/swift/comments/1",
          selfText: "Long-form post body goes here so the detail pane can render readable content.",
          postHint: "image"
        ))
    }
  }
}
