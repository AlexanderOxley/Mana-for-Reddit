//
//  ThirdPartyInstagramView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyInstagramView: View {
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
        .frame(minHeight: 520)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
  }
}

#Preview {
  ThirdPartyInstagramView(
    embed: ThirdPartyEmbed(
      provider: .instagram,
      url: URL(string: "https://www.instagram.com/p/Cx12345")!,
      title: "Instagram Post",
      providerName: "Instagram"
    )
  )
  .padding()
}
