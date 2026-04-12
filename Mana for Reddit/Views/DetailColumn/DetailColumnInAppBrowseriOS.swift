//
//  DetailColumnInAppBrowseriOS.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

#if os(iOS)
  import SafariServices
  import SwiftUI

  struct DetailColumnInAppBrowserView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
      SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
  }

  #Preview("iOS In-App Browser") {
    DetailColumnInAppBrowserView(url: URL(string: "https://www.reddit.com")!)
      .ignoresSafeArea()
  }
#endif
