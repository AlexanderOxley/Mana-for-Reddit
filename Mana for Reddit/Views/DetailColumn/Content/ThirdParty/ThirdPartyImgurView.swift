//
//  ThirdPartyImgurView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyImgurView: View {
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
      string: "https://www.reddit.com/r/PoliticalHumor/comments/1sjmkgb/not_all_first_ladies_were_porn_stars/")!,
    fallbackEmbed: ThirdPartyEmbed(
      provider: .imgur,
      url: URL(string: "https://imgur.com/gallery/example")!,
      title: "Imgur Gallery",
      providerName: "Imgur"
    ),
    expectedProvider: .imgur
  ) { embed in
    ThirdPartyImgurView(embed: embed)
  }
  .padding()
}
