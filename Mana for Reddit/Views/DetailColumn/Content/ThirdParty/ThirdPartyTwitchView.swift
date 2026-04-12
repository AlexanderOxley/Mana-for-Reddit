//
//  ThirdPartyTwitchView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyTwitchView: View {
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
      string:
        "https://www.reddit.com/r/formula1/comments/1sjla8x/ot_how_many_formula_1_race_wins_do_you_have_max/"
    )!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .twitch,
      url: URL(string: "https://www.twitch.tv/videos/123456")!,
      title: "Twitch Clip",
      providerName: "Twitch"
    ),
    expectedProvider: .twitch
  ) { embed in
    ThirdPartyTwitchView(embed: embed)
  }
  .padding()
}
