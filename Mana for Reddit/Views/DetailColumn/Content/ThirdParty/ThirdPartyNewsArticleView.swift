//
//  ThirdPartyNewsArticleView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyNewsArticleView: View {
  let embed: ThirdPartyEmbed

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = embed.title,
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
        Text(title)
          .font(.subheadline)
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
  ThirdPartyNewsArticleView(
    embed: ThirdPartyEmbed(
      provider: .nytimes,
      url: URL(string: "https://www.nytimes.com/example")!,
      title: "News Article",
      providerName: "NYTimes"
    )
  )
  .padding()
}
