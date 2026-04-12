//
//  EmbeddedStreamffmacOS.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import SwiftUI
import WebKit

#if os(macOS)
  struct EmbeddedStreamffmacOS: NSViewRepresentable {
    let url: URL

    final class Coordinator {
      var loadedURL: URL?
    }

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsAirPlayForMediaPlayback = true
      configuration.defaultWebpagePreferences.allowsContentJavaScript = true

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.setValue(false, forKey: "drawsBackground")
      load(url: url, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
      load(url: url, into: nsView, coordinator: context.coordinator)
    }

    private func load(url: URL, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedURL != url else { return }
      webView.load(URLRequest(url: url))
      coordinator.loadedURL = url
    }
  }
#endif
