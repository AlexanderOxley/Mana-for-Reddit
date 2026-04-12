//
//  ThirdPartyInstagramView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyInstagramView: View {
  let embed: ThirdPartyEmbed
  @StateObject private var viewModel: InstagramViewModel

  init(embed: ThirdPartyEmbed) {
    self.embed = embed
    _viewModel = StateObject(wrappedValue: InstagramViewModel(embed: embed))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = viewModel.titleText {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      #if os(iOS)
        EmbeddedInstagramiOS(html: viewModel.embedHTML, baseURL: viewModel.baseURL)
          .frame(minHeight: 520)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      #elseif os(macOS)
        EmbeddedInstagrammacOS(html: viewModel.embedHTML, baseURL: viewModel.baseURL)
          .frame(minHeight: 520)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      #endif

    }
    .onChange(of: embed) { _, newEmbed in
      viewModel.update(embed: newEmbed)
    }
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string:
        "https://www.reddit.com/r/wildcats/comments/1sjl82o/trent_noah_will_return_for_his_3rd_season_at/"
    )!,
    expectedProvider: .instagram
  ) { embed in
    ThirdPartyInstagramView(embed: embed)
  }
  .padding()
}
