//
//  ThirdPartyGenericWebEmbedView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyGenericWebEmbedView: View {
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
        .frame(minHeight: 300)
        .clipShape(RoundedRectangle(cornerRadius: 10))

      Text(embed.url.host() ?? embed.url.absoluteString)
        .font(.caption)
        .foregroundStyle(.secondary)
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
      provider: .other,
      url: URL(string: "https://streamff.link/v/example")!,
      title: "Streamff Video",
      providerName: "streamff.link"
    ),
    expectedProvider: .other
  ) { embed in
    ThirdPartyGenericWebEmbedView(embed: embed)
  }
  .padding()
}
