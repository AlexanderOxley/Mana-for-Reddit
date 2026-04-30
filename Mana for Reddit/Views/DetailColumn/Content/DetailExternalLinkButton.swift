//
//  DetailExternalLinkButton.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 30.04.2026.
//

import SwiftUI

struct DetailExternalLinkButton: View {
  let externalURL: URL

  private var displayHost: String {
    let host = externalURL.host()?.lowercased() ?? externalURL.absoluteString
    if host.hasPrefix("www.") {
      return String(host.dropFirst(4))
    }
    return host
  }

  var body: some View {
    Link(destination: externalURL) {
      HStack(spacing: 12) {
        Image(systemName: "link")
          .font(.title3)

        Text(displayHost)
          .font(.headline)
          .lineLimit(1)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .foregroundStyle(.white)
      .padding(18)
      .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
      .background(
        LinearGradient(
          colors: [Color.blue, Color.cyan],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(.white.opacity(0.25), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  DetailExternalLinkButton(
    externalURL: URL(string: "https://www.bbc.com/news/live/c3ve2nr60xzt")!
  )
  .padding()
}
