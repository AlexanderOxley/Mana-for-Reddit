//
//  EmbeddedInstagrammacOS.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 13.04.2026.
//

import SwiftUI
import WebKit

#if os(macOS)
  struct EmbeddedInstagrammacOS: NSViewRepresentable {
    let html: String
    let baseURL: URL

    final class Coordinator {
      var loadedHTML: String?
    }

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsAirPlayForMediaPlayback = true

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.setValue(false, forKey: "drawsBackground")
      load(html: html, into: webView, coordinator: context.coordinator)
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
      load(html: html, into: nsView, coordinator: context.coordinator)
    }

    private func load(html: String, into webView: WKWebView, coordinator: Coordinator) {
      guard coordinator.loadedHTML != html else { return }
      webView.loadHTMLString(html, baseURL: baseURL)
      coordinator.loadedHTML = html
    }
  }
#endif
