//
//  DetailColumnInAppBrowsermacOS.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

#if os(macOS)
  import SwiftUI
  import WebKit

  struct DetailColumnInAppBrowserView: NSViewRepresentable {
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

  #Preview("macOS In-App Browser") {
    DetailColumnInAppBrowserView(url: URL(string: "https://www.reddit.com")!)
      .frame(minWidth: 700, minHeight: 500)
  }
#endif
