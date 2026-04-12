//
//  StreamffViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Combine
import Foundation

@MainActor
final class StreamffViewModel: ObservableObject {
  @Published private(set) var titleText: String?
  @Published private(set) var pageURL: URL
  @Published private(set) var directVideoURL: URL?

  private var resolveTask: Task<Void, Never>?

  init(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    pageURL = Self.normalizedPageURL(from: embed.url)
    resolveDirectVideo()
  }

  func update(embed: ThirdPartyEmbed) {
    titleText = Self.normalizedTitle(embed.title)
    pageURL = Self.normalizedPageURL(from: embed.url)
    resolveDirectVideo()
  }

  deinit {
    resolveTask?.cancel()
  }

  private static func normalizedTitle(_ title: String?) -> String? {
    guard let title else { return nil }
    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }

  private static func normalizedPageURL(from url: URL) -> URL {
    StreamffVideo(url: url)?.canonicalURL ?? url
  }

  private func resolveDirectVideo() {
    resolveTask?.cancel()
    directVideoURL = nil

    let pageURL = self.pageURL
    Self.debugLog("Resolving media for page: \(pageURL.absoluteString)")
    resolveTask = Task { [weak self] in
      guard let self else { return }
      let resolvedURL = await Self.extractDirectVideoURL(from: pageURL)
      guard !Task.isCancelled else { return }
      self.directVideoURL = resolvedURL
      if let resolvedURL {
        Self.debugLog("Using DIRECT video URL: \(resolvedURL.absoluteString)")
      } else {
        Self.debugLog("Using FALLBACK web embed URL: \(pageURL.absoluteString)")
      }
    }
  }

  private static func extractDirectVideoURL(from pageURL: URL) async -> URL? {
    if let apiURL = await extractDirectVideoURLFromShareAPI(pageURL: pageURL) {
      return apiURL
    }

    debugLog("Share API did not return a direct URL, falling back to HTML scan")

    var request = URLRequest(url: pageURL)
    request.setValue("ios:com.mana.reddit:v1.0 (by /u/mana-app)", forHTTPHeaderField: "User-Agent")

    guard let (data, response) = try? await URLSession.shared.data(for: request),
      let http = response as? HTTPURLResponse,
      (200...299).contains(http.statusCode),
      let html = String(data: data, encoding: .utf8)
    else {
      return nil
    }

    let patterns = [
      #"<meta[^>]*property=[\"']og:video[\"'][^>]*content=[\"']([^\"']+)[\"']"#,
      #"<meta[^>]*content=[\"']([^\"']+)[\"'][^>]*property=[\"']og:video[\"']"#,
      #"<source[^>]*src=[\"']([^\"']+)[\"'][^>]*type=[\"']video/[^\"']+[\"']"#,
      #"\"file\"\s*:\s*\"(https?:\\/\\/[^\"]+)\""#,
    ]

    for pattern in patterns {
      guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
      else {
        continue
      }
      let range = NSRange(html.startIndex..<html.endIndex, in: html)
      guard let match = regex.firstMatch(in: html, options: [], range: range),
        match.numberOfRanges > 1,
        let valueRange = Range(match.range(at: 1), in: html)
      else {
        continue
      }

      let raw = html[valueRange]
        .replacingOccurrences(of: "\\/", with: "/")
        .replacingOccurrences(of: "&amp;", with: "&")
        .trimmingCharacters(in: .whitespacesAndNewlines)

      guard !raw.isEmpty else { continue }
      let absolute = raw.hasPrefix("//") ? "https:\(raw)" : raw
      guard let candidate = URL(string: absolute, relativeTo: pageURL)?.absoluteURL else {
        continue
      }
      let lower = candidate.absoluteString.lowercased()
      if lower.contains(".mp4") || lower.contains(".m3u8") || lower.contains("video") {
        return candidate
      }
    }

    return nil
  }

  private static func extractDirectVideoURLFromShareAPI(pageURL: URL) async -> URL? {
    guard let videoID = StreamffVideo(url: pageURL)?.videoID,
      let apiURL = URL(string: "https://ffedge.streamff.com/share/\(videoID)")
    else {
      return nil
    }

    var request = URLRequest(url: apiURL)
    request.setValue("ios:com.mana.reddit:v1.0 (by /u/mana-app)", forHTTPHeaderField: "User-Agent")

    guard let (data, response) = try? await URLSession.shared.data(for: request),
      let http = response as? HTTPURLResponse,
      (200...299).contains(http.statusCode)
    else {
      debugLog("Share API request failed for id \(videoID)")
      return nil
    }

    guard let json = try? JSONSerialization.jsonObject(with: data) else {
      debugLog("Share API returned non-JSON payload for id \(videoID)")
      return nil
    }

    let firstItem: [String: Any]?
    if let array = json as? [[String: Any]] {
      firstItem = array.first
    } else if let dict = json as? [String: Any] {
      firstItem = dict
    } else {
      firstItem = nil
    }

    guard let item = firstItem else {
      debugLog("Share API returned no media object for id \(videoID)")
      return nil
    }

    if let externalURLString = item["external_url"] as? String {
      let cleaned = externalURLString.trimmingCharacters(in: .whitespacesAndNewlines)
      if !cleaned.isEmpty, let externalURL = URL(string: cleaned) {
        return externalURL
      }
    }

    if let path = item["path"] as? String {
      let cleaned = path.trimmingCharacters(in: .whitespacesAndNewlines)
      if !cleaned.isEmpty,
        let uploadedMP4 = URL(string: "https://ffedge.streamff.com/uploads/\(cleaned).mp4")
      {
        return uploadedMP4
      }
    }

    debugLog("Share API object missing direct URL fields for id \(videoID)")
    return nil
  }

  private static func debugLog(_ message: String) {
    #if DEBUG
      print("[StreamffViewModel] \(message)")
    #endif
  }
}
