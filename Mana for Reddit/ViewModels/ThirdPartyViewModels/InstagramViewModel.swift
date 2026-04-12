//
//  InstagramViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 12.04.2026.
//

import Combine
import Foundation

@MainActor
final class InstagramViewModel: ObservableObject {
  let baseURL = URL(string: "https://www.instagram.com")!
  @Published private(set) var embedHTML: String
  @Published private(set) var titleText: String?

  init(embed: ThirdPartyEmbed) {
    embedHTML = Self.embedHTML(from: embed.url)
    titleText = Self.normalizedTitle(embed.title)
  }

  func update(embed: ThirdPartyEmbed) {
    embedHTML = Self.embedHTML(from: embed.url)
    titleText = Self.normalizedTitle(embed.title)
  }

  private static func normalizedTitle(_ title: String?) -> String? {
    guard let title else { return nil }
    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }

  private static func embedHTML(from url: URL) -> String {
    guard let media = InstagramMedia(url: url) else {
      return ""
    }

    return embedHTML(for: media)
  }

  private static func embedHTML(for media: InstagramMedia) -> String {
    let embedURL = media.embedURL.absoluteString

    return """
      <!doctype html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <style>
          html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: transparent;
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
          }

          iframe {
            width: 100%;
            height: 100%;
            border: 0;
            background: white;
          }
        </style>
      </head>
      <body>
        <iframe
          src="\(embedURL)"
          allowtransparency="true"
          scrolling="no"
          allowfullscreen>
        </iframe>
      </body>
      </html>
      """
  }
}
