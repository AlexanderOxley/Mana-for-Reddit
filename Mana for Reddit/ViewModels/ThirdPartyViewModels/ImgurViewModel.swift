//
//  ImgurViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Combine
import Foundation

@MainActor
final class ImgurViewModel: ObservableObject {
  @Published private(set) var titleText: String?
  @Published private(set) var imageURLCandidates: [URL]
  @Published private(set) var destinationURL: URL

  init(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    let resolved = Self.resolvedMedia(from: embed.url)
    imageURLCandidates = resolved.imageURLCandidates
    destinationURL = resolved.destinationURL
  }

  func update(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    let resolved = Self.resolvedMedia(from: embed.url)
    imageURLCandidates = resolved.imageURLCandidates
    destinationURL = resolved.destinationURL
  }

  private static func normalizedTitle(_ title: String?) -> String? {
    guard let title else { return nil }
    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }

  private static func resolvedMedia(from url: URL) -> (
    imageURLCandidates: [URL], destinationURL: URL
  ) {
    guard let media = ImgurMedia(url: url) else {
      return ([], url)
    }
    return (media.imageURLCandidates, media.canonicalURL)
  }
}
