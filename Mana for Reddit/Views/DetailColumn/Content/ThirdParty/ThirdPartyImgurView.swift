//
//  ThirdPartyImgurView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct ThirdPartyImgurView: View {
  let embed: ThirdPartyEmbed
  @StateObject private var viewModel: ImgurViewModel

  init(embed: ThirdPartyEmbed) {
    self.embed = embed
    _viewModel = StateObject(wrappedValue: ImgurViewModel(embed: embed))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title = viewModel.titleText {
        Text(title)
          .font(.subheadline)
          .lineLimit(2)
      }

      ImgurImageContentView(
        imageURLCandidates: viewModel.imageURLCandidates,
        fallbackURL: viewModel.destinationURL
      )
    }
    .onChange(of: embed) { _, newEmbed in
      viewModel.update(embed: newEmbed)
    }
  }
}

private struct ImgurImageContentView: View {
  let imageURLCandidates: [URL]
  let fallbackURL: URL

  @State private var candidateIndex = 0

  var body: some View {
    if let imageURL = currentCandidateURL {
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(maxWidth: .infinity, minHeight: 240)
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        case .failure:
          if hasNextCandidate {
            Color.clear
              .frame(maxWidth: .infinity, minHeight: 240)
              .onAppear {
                candidateIndex += 1
              }
          } else {
            browserFallback
          }
        @unknown default:
          browserFallback
        }
      }
      .onChange(of: imageURLCandidates) { _, _ in
        candidateIndex = 0
      }
    } else {
      browserFallback
    }
  }

  private var currentCandidateURL: URL? {
    guard imageURLCandidates.indices.contains(candidateIndex) else { return nil }
    return imageURLCandidates[candidateIndex]
  }

  private var hasNextCandidate: Bool {
    candidateIndex + 1 < imageURLCandidates.count
  }

  private var browserFallback: some View {
    DetailColumnInAppBrowserView(url: fallbackURL)
      .frame(minHeight: 360)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

#Preview {
  ThirdPartyPreviewRedditPostLoader(
    redditPostURL: URL(
      string:
        "https://www.reddit.com/r/PoliticalHumor/comments/1sjmkgb/not_all_first_ladies_were_porn_stars/"
    )!,
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
