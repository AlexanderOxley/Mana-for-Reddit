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
    let hasRenderableMediaOrText =
      !item.galleryImageURLs.isEmpty
      || item.videoURL != nil
      || item.imageURL != nil
      || !item.selfText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    let unsupportedContentURL =
      (hasRenderableMediaOrText || !item.isExternalLink) ? nil : item.contentURL

    VStack(alignment: .leading, spacing: 12) {
      if !item.galleryImageURLs.isEmpty {
        DetailPostGalleryView(imageURLs: item.galleryImageURLs)
      } else if let videoURL = item.videoURL {
        DetailPostVideoView(videoURL: videoURL)
      } else if let imageURL = item.imageURL {
        DetailPostImageView(imageURL: imageURL)
      }

      if !item.selfText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        MarkdownTextView(markdown: item.selfText, font: .body)
      }

      if !hasRenderableMediaOrText {
        Text("No post body available.")
          .foregroundStyle(.secondary)

        if let externalURL = unsupportedContentURL {
          DetailColumnInAppBrowserView(url: externalURL)
            .frame(minHeight: 360)

          Text(externalURL.absoluteString)
            .font(.caption)
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
        }
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
