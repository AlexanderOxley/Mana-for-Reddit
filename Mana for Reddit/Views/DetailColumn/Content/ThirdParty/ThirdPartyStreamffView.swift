//
//  ThirdPartyStreamffView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 12.04.2026.
//

import SwiftUI

struct ThirdPartyStreamffView: View {
  let embed: ThirdPartyEmbed

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = embed.title,
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      DetailColumnInAppBrowserView(url: embed.url)
        .frame(minHeight: 360)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string:
        "https://www.reddit.com/r/soccer/comments/1sjfuig/sunderland_10_tottenham_nordi_mukiele_61/"
    )!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .streamff,
      url: URL(string: "https://streamff.link/v/example")!,
      title: "Streamff Video",
      providerName: "streamff.link"
    ),
    expectedProvider: .streamff
  ) { embed in
    ThirdPartyStreamffView(embed: embed)
  }
  .padding()
}
