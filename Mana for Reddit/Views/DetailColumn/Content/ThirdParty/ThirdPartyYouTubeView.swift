//
//  ThirdPartyYouTubeView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI
import WebKit

struct ThirdPartyYouTubeView: View {
  let embed: ThirdPartyEmbed
  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = embed.title,
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      if let videoID = Self.extractVideoID(from: embed.url) {
        EmbeddedYouTubePlayerView(videoID: videoID)
          .frame(minHeight: 260)
          .aspectRatio(16 / 9, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        VStack(alignment: .leading, spacing: 6) {
          Text("Could not parse a playable YouTube video ID.")
            .font(.caption)
            .foregroundStyle(.secondary)

          Button("Open on YouTube") {
            openURL(embed.url)
          }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
      }
    }
  }

  private static func extractVideoID(from url: URL) -> String? {
    let host = url.host?.lowercased() ?? ""
    let pathComponents = url.pathComponents.filter { $0 != "/" }

    if host == "youtu.be", let first = pathComponents.first {
      return normalizedVideoID(first)
    }

    if host.contains("youtube.com") {
      if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let vValue = components.queryItems?.first(where: { $0.name == "v" })?.value
      {
        return normalizedVideoID(vValue)
      }

      if let markerIndex = pathComponents.firstIndex(of: "embed"),
        pathComponents.indices.contains(markerIndex + 1)
      {
        return normalizedVideoID(pathComponents[markerIndex + 1])
      }

      if let markerIndex = pathComponents.firstIndex(of: "shorts"),
        pathComponents.indices.contains(markerIndex + 1)
      {
        return normalizedVideoID(pathComponents[markerIndex + 1])
      }

      if let markerIndex = pathComponents.firstIndex(of: "live"),
        pathComponents.indices.contains(markerIndex + 1)
      {
        return normalizedVideoID(pathComponents[markerIndex + 1])
      }
    }

    return nil
  }

  private static func normalizedVideoID(_ value: String) -> String? {
    let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return nil }
    let candidate = cleaned.components(separatedBy: "?").first ?? cleaned
    let allowed = CharacterSet(
      charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
    let sanitized = String(candidate.unicodeScalars.filter { allowed.contains($0) })
    guard !sanitized.isEmpty else { return nil }
    return sanitized
  }
}

private struct EmbeddedYouTubePlayerView: View {
  let videoID: String

  var body: some View {
    #if os(iOS)
      EmbeddedYouTubePlayeriOS(videoID: videoID)
    #elseif os(macOS)
      EmbeddedYouTubePlayermacOS(videoID: videoID)
    #else
      Text("YouTube embed is not supported on this platform.")
        .font(.caption)
        .foregroundStyle(.secondary)
    #endif
  }
}

#if os(iOS)
  private struct EmbeddedYouTubePlayeriOS: UIViewRepresentable {
    let videoID: String

    final class Coordinator {
      var loadedVideoID: String?
    }

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsInlineMediaPlayback = true
      configuration.mediaTypesRequiringUserActionForPlayback = []

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.scrollView.isScrollEnabled = false
      webView.isOpaque = false
      webView.backgroundColor = .clear
      load(videoID: videoID, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
      load(videoID: videoID, into: uiView, coordinator: context.coordinator)
    }

    private func load(videoID: String, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedVideoID != videoID else { return }
      let html = EmbeddedYouTubeHTMLBuilder.document(videoID: videoID)
      webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
      coordinator.loadedVideoID = videoID
    }
  }
#endif

#if os(macOS)
  private struct EmbeddedYouTubePlayermacOS: NSViewRepresentable {
    let videoID: String

    final class Coordinator {
      var loadedVideoID: String?
    }

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsAirPlayForMediaPlayback = true

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.setValue(false, forKey: "drawsBackground")
      load(videoID: videoID, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
      load(videoID: videoID, into: nsView, coordinator: context.coordinator)
    }

    private func load(videoID: String, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedVideoID != videoID else { return }
      let html = EmbeddedYouTubeHTMLBuilder.document(videoID: videoID)
      webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
      coordinator.loadedVideoID = videoID
    }
  }
#endif

private enum EmbeddedYouTubeHTMLBuilder {
  static func document(videoID: String) -> String {
    let escapedID = videoID.replacingOccurrences(of: "\"", with: "")

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
            background: black;
          }

          .player {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            border: 0;
          }
        </style>
      </head>
      <body>
        <iframe
          class="player"
          src="https://www.youtube-nocookie.com/embed/\(escapedID)?playsinline=1&rel=0&modestbranding=1"
          title="YouTube video player"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          referrerpolicy="strict-origin-when-cross-origin"
          allowfullscreen>
        </iframe>
      </body>
      </html>
      """
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string:
        "https://www.reddit.com/r/msnow/comments/1sjq1oe/breaking_hungarian_prime_minister_viktor_orb%C3%A1n/"
    )!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .youtube,
      url: URL(string: "https://www.youtube.com/watch?v=J8uLWPHu1sI")!,
      title: "Never Gonna Give You Up",
      providerName: "YouTube"
    ),
    expectedProvider: .youtube
  ) { embed in
    ThirdPartyYouTubeView(embed: embed)
  }
  .padding()
}
