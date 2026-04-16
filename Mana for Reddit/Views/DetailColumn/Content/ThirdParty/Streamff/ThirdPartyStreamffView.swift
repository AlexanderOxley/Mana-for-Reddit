//
//  ThirdPartyStreamffView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 12.04.2026.
//

import AVKit
import SwiftUI

struct ThirdPartyStreamffView: View {
  let embed: ThirdPartyEmbed
  @StateObject private var viewModel: StreamffViewModel

  init(embed: ThirdPartyEmbed) {
    self.embed = embed
    _viewModel = StateObject(wrappedValue: StreamffViewModel(embed: embed))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = viewModel.titleText {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      if let directVideoURL = viewModel.directVideoURL {
        #if os(macOS)
          NativeVideoPlayer(player: AVPlayer(url: directVideoURL))
            .frame(minHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #else
          VideoPlayer(player: AVPlayer(url: directVideoURL))
            .frame(minHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #endif
      } else {
        #if os(iOS)
          EmbeddedStreamffiOS(url: viewModel.pageURL)
            .frame(minHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #elseif os(macOS)
          EmbeddedStreamffmacOS(url: viewModel.pageURL)
            .frame(minHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        #else
          Text("Streamff embed is not supported on this platform.")
            .font(.caption)
            .foregroundStyle(.secondary)
        #endif
      }
    }
    .onChange(of: embed) { _, newEmbed in
      viewModel.update(embed: newEmbed)
    }
  }
}

#Preview {
  ThirdPartyStreamffView(
    embed: ThirdPartyEmbed(
      provider: .streamff,
      url: URL(string: "https://streamff.com/v/91060752")!,
      title: "Sunderland 1-0 Tottenham",
      providerName: "streamff"
    )
  )
  .padding()
}
