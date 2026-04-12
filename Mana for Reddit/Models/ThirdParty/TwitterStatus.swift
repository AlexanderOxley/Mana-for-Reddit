//
//  TwitterStatus.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Foundation

struct TwitterStatus {
  let username: String
  let statusID: String

  var canonicalURL: URL {
    URL(string: "https://twitter.com/\(username)/status/\(statusID)")!
  }

  var embedURL: URL {
    var components = URLComponents(string: "https://platform.twitter.com/embed/Tweet.html")!
    components.queryItems = [
      URLQueryItem(name: "id", value: statusID),
      URLQueryItem(name: "dnt", value: "true"),
    ]
    return components.url!
  }

  init?(url: URL) {
    guard let host = url.host?.lowercased() else { return nil }
    let validHost = host.contains("x.com") || host.contains("twitter.com")
    guard validHost else { return nil }

    let pathComponents = url.pathComponents.filter { $0 != "/" }
    guard pathComponents.count >= 3 else { return nil }

    if let statusIndex = pathComponents.firstIndex(where: { $0.lowercased() == "status" }),
      pathComponents.indices.contains(statusIndex + 1)
    {
      let rawStatusID = pathComponents[statusIndex + 1]
      let statusID = Self.normalizedStatusID(rawStatusID)
      guard !statusID.isEmpty else { return nil }

      // Typical path: /{username}/status/{id}
      if statusIndex >= 1 {
        let username = pathComponents[statusIndex - 1].trimmingCharacters(
          in: .whitespacesAndNewlines)
        guard !username.isEmpty else { return nil }
        self.username = username
        self.statusID = statusID
        return
      }

      // Fallback path shape (for odd share links) still provides an embed-capable id.
      self.username = "i"
      self.statusID = statusID
      return
    }

    return nil
  }

  private static func normalizedStatusID(_ value: String) -> String {
    let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
    let candidate =
      cleaned.components(separatedBy: "?").first?.components(separatedBy: "#").first ?? ""
    let digits = String(candidate.filter { $0.isNumber })
    return digits
  }
}
