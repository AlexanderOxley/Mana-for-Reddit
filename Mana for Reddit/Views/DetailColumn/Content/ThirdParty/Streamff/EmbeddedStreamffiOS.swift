//
//  EmbeddedStreamffiOS.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import SwiftUI
import WebKit

#if os(iOS)
  struct EmbeddedStreamffiOS: UIViewRepresentable {
    let url: URL

    final class Coordinator {
      var loadedURL: URL?
    }

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsInlineMediaPlayback = true
      configuration.mediaTypesRequiringUserActionForPlayback = []
      configuration.defaultWebpagePreferences.allowsContentJavaScript = true

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.isOpaque = false
      webView.backgroundColor = .clear
      load(url: url, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
      load(url: url, into: uiView, coordinator: context.coordinator)
    }

    private func load(url: URL, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedURL != url else { return }
      webView.load(URLRequest(url: url))
      coordinator.loadedURL = url
    }
  }
#endif
