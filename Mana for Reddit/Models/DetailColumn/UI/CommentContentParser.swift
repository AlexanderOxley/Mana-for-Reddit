//
//  CommentContentParser.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 30.04.2026.
//

import Foundation

struct CommentContent {
  let displayBodyMarkdown: String?
  let previewImageURL: URL?
  let gifURL: URL?
  let hasMediaOnlyBodyToken: Bool
}

enum CommentContentParser {
  static func parse(body: String) -> CommentContent {
    let urls = detectedURLs(in: body)

    let previewImageURL = urls.first(where: isRedditPreviewImageURL)

    var gifURL: URL?
    for url in urls {
      if let giphyURL = normalizedGiphyURL(from: url) {
        gifURL = giphyURL
        break
      }

      if isRedditExternalGIFURL(url) {
        gifURL = url
        break
      }
    }

    if gifURL == nil {
      gifURL = giphyTokenURL(in: body)
    }

    let hasMediaOnlyBodyToken =
      isMediaOnlyMarkdownToken(body)
      && (gifURL != nil || previewImageURL != nil)

    return CommentContent(
      displayBodyMarkdown: hasMediaOnlyBodyToken ? nil : body,
      previewImageURL: previewImageURL,
      gifURL: gifURL,
      hasMediaOnlyBodyToken: hasMediaOnlyBodyToken
    )
  }

  private static func detectedURLs(in body: String) -> [URL] {
    let range = NSRange(body.startIndex..<body.endIndex, in: body)
    let matches = urlDetector.matches(in: body, options: [], range: range)

    return matches.compactMap { match in
      guard let urlRange = Range(match.range, in: body) else { return nil }
      return normalizedURL(from: String(body[urlRange]))
    }
  }

  private static func normalizedURL(from rawValue: String) -> URL? {
    URL(string: rawValue.replacingOccurrences(of: "&amp;", with: "&"))
  }

  private static func isRedditPreviewImageURL(_ url: URL) -> Bool {
    guard let host = url.host?.lowercased() else { return false }
    guard host.hasSuffix("preview.redd.it") || host.hasSuffix("external-preview.redd.it") else {
      return false
    }

    let path = url.path.lowercased()
    return path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") || path.hasSuffix(".png")
      || path.hasSuffix(".webp")
  }

  private static func isRedditExternalGIFURL(_ url: URL) -> Bool {
    guard let host = url.host?.lowercased(), host.hasSuffix("external-preview.redd.it") else {
      return false
    }

    let path = url.path.lowercased()
    if path.hasSuffix(".gif") { return true }

    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return false
    }

    if let formatValue = components.queryItems?.first(where: { $0.name == "format" })?.value?
      .lowercased(),
      formatValue == "mp4" || formatValue == "gif"
    {
      return true
    }

    return false
  }

  private static func normalizedGiphyURL(from url: URL) -> URL? {
    guard let host = url.host?.lowercased() else { return nil }

    if (host.contains("i.giphy.com") || host.contains("media.giphy.com"))
      && url.path.lowercased().hasSuffix(".gif")
    {
      return url
    }

    guard host.hasSuffix("giphy.com") else { return nil }

    let components = url.path.split(separator: "/")
    if let mediaIndex = components.firstIndex(of: "media"), components.count > mediaIndex + 1 {
      let id = String(components[mediaIndex + 1])
      return URL(string: "https://i.giphy.com/\(id).gif")
    }

    if let last = components.last {
      let value = String(last)
      if let id = value.split(separator: "-").last, !id.isEmpty {
        return URL(string: "https://i.giphy.com/\(id).gif")
      }
    }

    return nil
  }

  private static func giphyTokenURL(in body: String) -> URL? {
    let range = NSRange(body.startIndex..<body.endIndex, in: body)
    guard
      let match = giphyTokenRegex.firstMatch(in: body, options: [], range: range),
      match.numberOfRanges > 1,
      let idRange = Range(match.range(at: 1), in: body)
    else {
      return nil
    }

    let giphyID = String(body[idRange])
    guard !giphyID.isEmpty else { return nil }
    return URL(string: "https://i.giphy.com/\(giphyID).gif")
  }

  private static func isMediaOnlyMarkdownToken(_ body: String) -> Bool {
    let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
    return mediaOnlyMarkdownRegex.firstMatch(in: trimmed, options: [], range: range) != nil
  }

  private static let giphyTokenRegex: NSRegularExpression = {
    try! NSRegularExpression(pattern: "giphy\\|([A-Za-z0-9_-]+)")
  }()

  private static let mediaOnlyMarkdownRegex: NSRegularExpression = {
    try! NSRegularExpression(
      pattern: "^!\\[[^\\]]*\\]\\((?:giphy\\|[A-Za-z0-9_-]+|https?://[^)]+)\\)$")
  }()

  private static let urlDetector: NSDataDetector = {
    try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
  }()
}
