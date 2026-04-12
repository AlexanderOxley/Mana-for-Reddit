//
//  ThirdPartyTwitterView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyTwitterView: View {
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
        .frame(minHeight: 460)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string:
        "https://www.reddit.com/r/Conservative/comments/1sjhc30/iran_played_its_biggest_card_and_the_main_result/"
    )!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .twitter,
      url: URL(string: "https://x.com/SwiftLang/status/123")!,
      title: "X Post",
      providerName: "Twitter"
    ),
    expectedProvider: .twitter
  ) { embed in
    ThirdPartyTwitterView(embed: embed)
  }
  .padding()
}
