//
//  EmbeddedInstagramiOS.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 13.04.2026.
//

import SwiftUI
import WebKit

#if os(iOS)
  struct EmbeddedInstagramiOS: UIViewRepresentable {
    let html: String
    let baseURL: URL

    final class Coordinator {
      var loadedHTML: String?
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
      load(html: html, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
      load(html: html, into: uiView, coordinator: context.coordinator)
    }

    private func load(html: String, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedHTML != html else { return }
      webView.loadHTMLString(html, baseURL: baseURL)
      coordinator.loadedHTML = html
    }
  }
#endif
