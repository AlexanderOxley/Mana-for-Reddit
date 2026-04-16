//
//  DetailPostVideoView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import AVKit
import SwiftUI

#if os(macOS)
  struct NativeVideoPlayer: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
      let view = AVPlayerView()
      view.player = player
      view.controlsStyle = .inline
      return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
      nsView.player = player
    }
  }
#endif

struct DetailPostVideoView: View {
  let videoURL: URL

  var body: some View {
    #if os(macOS)
      NativeVideoPlayer(player: AVPlayer(url: videoURL))
        .frame(minHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    #else
      VideoPlayer(player: AVPlayer(url: videoURL))
        .frame(minHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    #endif
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
