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
  ThirdPartyTwitchView(
    embed: ThirdPartyEmbed(
      provider: .twitch,
      url: URL(string: "https://www.twitch.tv/videos/123456")!,
      title: "Twitch Clip",
      providerName: "Twitch"
    )
  )
  .padding()
}
