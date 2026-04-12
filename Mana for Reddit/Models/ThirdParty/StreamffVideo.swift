//
//  StreamffVideo.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Foundation

struct StreamffVideo {
  let videoID: String

  var canonicalURL: URL {
    URL(string: "https://streamff.com/v/\(videoID)")!
  }

  init?(url: URL) {
    let host = url.host?.lowercased() ?? ""
    guard host.contains("streamff.com") || host.contains("streamff.link") else {
      return nil
    }

    let pathComponents = url.pathComponents.filter { $0 != "/" }
    guard !pathComponents.isEmpty else { return nil }

    if pathComponents.count >= 2 && pathComponents[0].lowercased() == "v" {
      let id = Self.normalizedID(pathComponents[1])
      guard !id.isEmpty else { return nil }
      videoID = id
      return
    }

    let id = Self.normalizedID(pathComponents[0])
    guard !id.isEmpty else { return nil }
    videoID = id
  }

  private static func normalizedID(_ value: String) -> String {
    value
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: "?")
      .first?
      .components(separatedBy: "#")
      .first ?? ""
  }
}
