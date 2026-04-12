//
//  TwitterViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Combine
import Foundation

@MainActor
final class TwitterViewModel: ObservableObject {
  @Published private(set) var titleText: String?
  @Published private(set) var embedURL: URL?
  @Published private(set) var fallbackURL: URL

  init(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    embedURL = Self.embedURL(from: embed.url)
    fallbackURL = Self.fallbackURL(from: embed.url)
  }

  func update(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    embedURL = Self.embedURL(from: embed.url)
    fallbackURL = Self.fallbackURL(from: embed.url)
  }

  private static func normalizedTitle(_ title: String?) -> String? {
    guard let title else { return nil }
    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }

  private static func fallbackURL(from url: URL) -> URL {
    TwitterStatus(url: url)?.canonicalURL ?? url
  }

  private static func embedURL(from url: URL) -> URL? {
    TwitterStatus(url: url)?.embedURL
  }
}
