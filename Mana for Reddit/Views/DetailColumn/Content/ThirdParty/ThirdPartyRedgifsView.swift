//
//  ThirdPartyRedgifsView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyRedgifsView: View {
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
        .frame(minHeight: 420)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string: "https://www.reddit.com/r/JizzedToThis/comments/1sjn4sl/wild_guessing_game/")!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .redgifs,
      url: URL(string: "https://www.redgifs.com/watch/example")!,
      title: "Redgifs Clip",
      providerName: "Redgifs"
    ),
    expectedProvider: .redgifs
  ) { embed in
    ThirdPartyRedgifsView(embed: embed)
  }
  .padding()
}
