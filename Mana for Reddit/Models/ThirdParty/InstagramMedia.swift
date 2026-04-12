//
//  InstagramMedia.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 13.04.2026.
//

import Foundation

struct InstagramMedia {
  enum Kind: String {
    case post = "p"
    case reel = "reel"
    case tv = "tv"
  }

  let kind: Kind
  let identifier: String

  var canonicalURL: URL {
    URL(string: "https://www.instagram.com/\(kind.rawValue)/\(identifier)/")!
  }

  var embedURL: URL {
    URL(string: "https://www.instagram.com/\(kind.rawValue)/\(identifier)/embed/captioned/")!
  }

  init?(url: URL) {
    let pathComponents = url.pathComponents.filter { $0 != "/" }
    guard !pathComponents.isEmpty else { return nil }

    if pathComponents.count >= 2,
      let kind = Kind(rawValue: pathComponents[0].lowercased())
    {
      let identifier = Self.normalizedIdentifier(pathComponents[1])
      guard !identifier.isEmpty else { return nil }
      self.kind = kind
      self.identifier = identifier
      return
    }

    if pathComponents.count >= 3,
      pathComponents[0].lowercased() == "share",
      let kind = Kind(rawValue: pathComponents[1].lowercased())
    {
      let identifier = Self.normalizedIdentifier(pathComponents[2])
      guard !identifier.isEmpty else { return nil }
      self.kind = kind
      self.identifier = identifier
      return
    }

    return nil
  }

  private static func normalizedIdentifier(_ rawValue: String) -> String {
    rawValue
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: "?")
      .first?
      .components(separatedBy: "#")
      .first ?? ""
  }
}
