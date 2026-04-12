//
//  ThirdPartyEmbedContainerView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyEmbedContainerView: View {
  let embed: ThirdPartyEmbed

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        Label(embed.provider.displayName, systemImage: providerIcon)
          .font(.caption)
          .foregroundStyle(.secondary)

        Text("Third-Party")
          .font(.caption2)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(.quaternary, in: Capsule())
      }

      if let providerName = embed.providerName,
        !providerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        providerName != embed.provider.displayName
      {
        Text(providerName)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }

      switch embed.provider {
      case .youtube:
        ThirdPartyYouTubeView(embed: embed)
      case .twitter:
        ThirdPartyTwitterView(embed: embed)
      case .streamff:
        ThirdPartyStreamffView(embed: embed)
      case .twitch:
        ThirdPartyTwitchView(embed: embed)
      case .tiktok:
        ThirdPartyTikTokView(embed: embed)
      case .instagram:
        ThirdPartyInstagramView(embed: embed)
      case .imgur:
        ThirdPartyImgurView(embed: embed)
      case .nytimes, .guardian, .bbc:
        ThirdPartyNewsArticleView(embed: embed)
      case .redgifs:
        ThirdPartyRedgifsView(embed: embed)
      default:
        ThirdPartyGenericWebEmbedView(embed: embed)
      }
    }
  }

  private var providerIcon: String {
    switch embed.provider {
    case .youtube: return "play.rectangle.fill"
    case .twitter: return "bubble.left.and.bubble.right.fill"
    case .redgifs: return "flame.fill"
    case .streamff: return "play.tv.fill"
    case .vimeo: return "video.fill"
    case .tiktok: return "music.note"
    case .instagram: return "camera.circle"
    case .twitch: return "gamecontroller.fill"
    case .imgur: return "photo.on.rectangle"
    case .nytimes, .guardian, .bbc: return "newspaper.fill"
    case .soundcloud: return "waveform"
    case .spotify: return "music.note.list"
    case .other: return "safari"
    }
  }
}

#Preview {
  ThirdPartyEmbedContainerView(
    embed: ThirdPartyEmbed(
      provider: .youtube,
      url: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!,
      title: "YouTube Preview",
      providerName: "YouTube"
    )
  )
  .padding()
}
