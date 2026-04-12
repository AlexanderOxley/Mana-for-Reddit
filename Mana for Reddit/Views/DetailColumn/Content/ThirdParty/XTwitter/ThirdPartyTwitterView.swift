//
//  ThirdPartyTwitterView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyTwitterView: View {
  let embed: ThirdPartyEmbed
  @StateObject private var viewModel: TwitterViewModel

  init(embed: ThirdPartyEmbed) {
    self.embed = embed
    _viewModel = StateObject(wrappedValue: TwitterViewModel(embed: embed))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = viewModel.titleText {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      if let embedURL = viewModel.embedURL {
        #if os(iOS)
          EmbeddedTwitteriOS(url: embedURL)
            .frame(minHeight: 460)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #elseif os(macOS)
          EmbeddedTwittermacOS(url: embedURL)
            .frame(minHeight: 460)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #else
          Text("Twitter/X embed is not supported on this platform.")
            .font(.caption)
            .foregroundStyle(.secondary)
        #endif
      } else {
        DetailColumnInAppBrowserView(url: viewModel.fallbackURL)
          .frame(minHeight: 460)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
    }
    .onChange(of: embed) { _, newEmbed in
      viewModel.update(embed: newEmbed)
    }
  }
}

#Preview {
  ThirdPartyTwitterView(
    embed: ThirdPartyEmbed(
      provider: .twitter,
      url: URL(string: "https://x.com/knesix/status/2043100554725929406?s=46")!,
      title: "Iran played its biggest card and the main result",
      providerName: "Twitter"
    )
  )
  .padding()
}
