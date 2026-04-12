//
//  CommentGIFView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI
import WebKit

struct CommentGIFView: View {
  let gifURL: URL

  var body: some View {
    GIFWebView(url: gifURL)
      .frame(minHeight: 220)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

#if os(iOS)
  private struct GIFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.scrollView.isScrollEnabled = false
      webView.isOpaque = false
      webView.backgroundColor = .clear
      webView.load(URLRequest(url: url))
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
      guard uiView.url != url else { return }
      uiView.load(URLRequest(url: url))
    }
  }
#elseif os(macOS)
  private struct GIFWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.load(URLRequest(url: url))
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
      guard nsView.url != url else { return }
      nsView.load(URLRequest(url: url))
    }
  }
#endif
