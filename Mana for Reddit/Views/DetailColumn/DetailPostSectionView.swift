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
    VStack(alignment: .leading, spacing: 12) {
      switch item.contentIntent {
      case .gallery(let imageURLs):
        DetailPostGalleryView(imageURLs: imageURLs)
      case .video(let videoURL):
        DetailPostVideoView(videoURL: videoURL)
      case .image(let imageURL):
        DetailPostImageView(imageURL: imageURL)
      case .text(let selfText):
        MarkdownTextView(markdown: selfText, font: .body)
      case .thirdParty(let embed):
        ThirdPartyEmbedContainerView(embed: embed)
      case .externalLink(let externalURL):
        Text("External content")
          .foregroundStyle(.secondary)
        DetailColumnInAppBrowserView(url: externalURL)
          .frame(minHeight: 360)

        Text(externalURL.host() ?? externalURL.absoluteString)
          .font(.caption)
          .foregroundStyle(.secondary)
      case .none:
        Text("No post body available.")
          .foregroundStyle(.secondary)
      }

      PostBadgesView(post: item)
      PostSupplementaryMetadataView(post: item)
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
