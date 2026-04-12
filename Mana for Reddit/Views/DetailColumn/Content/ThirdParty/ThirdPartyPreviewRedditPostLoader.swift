//
//  ThirdPartyPreviewRedditPostLoader.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 12.04.2026.
//

import SwiftUI

struct ThirdPartyPreviewRedditPostLoader<Content: View>: View {
  let redditPostURL: URL
  let fallbackEmbed: ThirdPartyEmbed?
  let expectedProvider: ThirdPartyProvider?
  let content: (ThirdPartyEmbed) -> Content

  @State private var loadedEmbed: ThirdPartyEmbed?
  @State private var loadError: String?

  init(
    redditPostURL: URL,
    fallbackEmbed: ThirdPartyEmbed? = nil,
    expectedProvider: ThirdPartyProvider? = nil,
    @ViewBuilder content: @escaping (ThirdPartyEmbed) -> Content
  ) {
    self.redditPostURL = redditPostURL
    self.fallbackEmbed = fallbackEmbed
    self.expectedProvider = expectedProvider
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let embed = loadedEmbed ?? fallbackEmbed {
        content(embed)
      } else if loadError == nil {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 120)
      }

      if let loadError {
        Text(loadError)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .task(id: redditPostURL) {
      await loadEmbed()
    }
  }

  @MainActor
  private func loadEmbed() async {
    do {
      let embed = try await Self.fetchThirdPartyEmbed(from: redditPostURL)
      loadedEmbed = embed

      if let expectedProvider, embed.provider != expectedProvider {
        loadError =
          "Preview loaded provider \(embed.provider.displayName), expected \(expectedProvider.displayName)."
      } else {
        loadError = nil
      }
    } catch {
      loadedEmbed = nil
      loadError = "Preview fallback used: \(error.localizedDescription)"
    }
  }

  private static func fetchThirdPartyEmbed(from redditPostURL: URL) async throws -> ThirdPartyEmbed
  {
    guard let jsonURL = jsonEndpointURL(from: redditPostURL) else {
      throw PreviewLoadError.invalidRedditURL
    }

    var request = URLRequest(url: jsonURL)
    request.setValue("ios:com.mana.reddit:v1.0 (by /u/mana-app)", forHTTPHeaderField: "User-Agent")

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
      throw PreviewLoadError.invalidResponse
    }

    if let listings = try? JSONDecoder().decode([PostListingDTO].self, from: data),
      let post = listings.first?.data.children.first?.data,
      let embed = post.thirdPartyEmbed
    {
      return embed
    }

    if let embed = try? extractEmbedDirectly(from: data) {
      return embed
    }

    throw PreviewLoadError.noThirdPartyEmbed
  }

  private static func extractEmbedDirectly(from data: Data) throws -> ThirdPartyEmbed {
    guard
      let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
      let listing = json.first,
      let listingData = listing["data"] as? [String: Any],
      let children = listingData["children"] as? [[String: Any]],
      let firstChild = children.first,
      let postData = firstChild["data"] as? [String: Any]
    else {
      throw PreviewLoadError.noThirdPartyEmbed
    }

    let title = postData["title"] as? String
    let providerName = extractProviderName(from: postData)
    let urlString =
      (postData["url_overridden_by_dest"] as? String)
      ?? (postData["url"] as? String)

    guard let urlString, let url = URL(string: urlString) else {
      throw PreviewLoadError.noThirdPartyEmbed
    }

    let provider = detectThirdPartyProvider(url: url, providerName: providerName)
    guard provider != .other || providerName != nil else {
      throw PreviewLoadError.noThirdPartyEmbed
    }

    return ThirdPartyEmbed(
      provider: provider,
      url: url,
      title: title,
      providerName: providerName
    )
  }

  private static func extractProviderName(from postData: [String: Any]) -> String? {
    if let secureMedia = postData["secure_media"] as? [String: Any],
      let oembed = secureMedia["oembed"] as? [String: Any],
      let providerName = oembed["provider_name"] as? String,
      !providerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return providerName
    }

    if let media = postData["media"] as? [String: Any],
      let oembed = media["oembed"] as? [String: Any],
      let providerName = oembed["provider_name"] as? String,
      !providerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return providerName
    }

    return nil
  }

  private static func detectThirdPartyProvider(url: URL, providerName: String?)
    -> ThirdPartyProvider
  {
    let host = url.host?.lowercased() ?? ""
    let provider = providerName?.lowercased() ?? ""

    if host.contains("youtube.com") || host.contains("youtu.be") || provider.contains("youtube") {
      return .youtube
    }
    if host.contains("twitter.com") || host.contains("x.com") || provider.contains("twitter") {
      return .twitter
    }
    if host.contains("redgifs.com") || host.contains("gfycat.com") || provider.contains("redgifs") {
      return .redgifs
    }
    if host.contains("streamff.link") || provider.contains("streamff") {
      return .streamff
    }
    if host.contains("vimeo.com") || provider.contains("vimeo") {
      return .vimeo
    }
    if host.contains("tiktok.com") || provider.contains("tiktok") {
      return .tiktok
    }
    if host.contains("instagram.com") || provider.contains("instagram") {
      return .instagram
    }
    if host.contains("twitch.tv") || provider.contains("twitch") {
      return .twitch
    }
    if host.contains("imgur.com") || provider.contains("imgur") {
      return .imgur
    }
    if host.contains("nytimes.com") || provider.contains("new york times") {
      return .nytimes
    }
    if host.contains("theguardian.com") || host.contains("guardian.co.uk")
      || provider.contains("guardian")
    {
      return .guardian
    }
    if host.contains("bbc.com") || host.contains("bbc.co.uk") || provider == "bbc" {
      return .bbc
    }
    if host.contains("soundcloud.com") || provider.contains("soundcloud") {
      return .soundcloud
    }
    if host.contains("spotify.com") || provider.contains("spotify") {
      return .spotify
    }
    return .other
  }

  private static func jsonEndpointURL(from redditPostURL: URL) -> URL? {
    guard var components = URLComponents(url: redditPostURL, resolvingAgainstBaseURL: false) else {
      return nil
    }

    var path = components.path
    if !path.hasSuffix("/") {
      path += "/"
    }
    path += ".json"
    components.path = path

    var queryItems = components.queryItems ?? []
    queryItems.removeAll { $0.name == "raw_json" || $0.name == "limit" }
    queryItems.append(URLQueryItem(name: "raw_json", value: "1"))
    queryItems.append(URLQueryItem(name: "limit", value: "1"))
    components.queryItems = queryItems

    return components.url
  }
}

private enum PreviewLoadError: LocalizedError {
  case invalidRedditURL
  case invalidResponse
  case noThirdPartyEmbed

  var errorDescription: String? {
    switch self {
    case .invalidRedditURL:
      return "Invalid Reddit post URL."
    case .invalidResponse:
      return "Reddit preview endpoint returned a non-200 response."
    case .noThirdPartyEmbed:
      return "Reddit post did not decode a third-party embed."
    }
  }
}
