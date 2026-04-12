//
//  DetailPostVideoView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import AVKit
import SwiftUI

struct DetailPostVideoView: View {
  let videoURL: URL

  var body: some View {
    VideoPlayer(player: AVPlayer(url: videoURL))
      .frame(minHeight: 240)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

#Preview {
  List {
    Section("Video") {
      DetailPostVideoView(
        videoURL: URL(string: "https://v.redd.it/7t0f1f5x5hsa1/DASH_720.mp4")!)
    }
  }
}
