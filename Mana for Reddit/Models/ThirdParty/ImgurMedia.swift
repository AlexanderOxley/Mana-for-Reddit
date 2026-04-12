//
//  ImgurMedia.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 13.04.2026.
//

import Foundation

struct ImgurMedia {
  enum Kind {
    case image
    case album
    case gallery
    case post
  }

  let kind: Kind
  let identifier: String
  let fileExtension: String?

  var canonicalURL: URL {
    switch kind {
    case .image, .post:
      return URL(string: "https://imgur.com/\(identifier)")!
    case .album:
      return URL(string: "https://imgur.com/a/\(identifier)")!
    case .gallery:
      return URL(string: "https://imgur.com/gallery/\(identifier)")!
    }
  }

  var imageURLCandidates: [URL] {
    guard kind == .image || kind == .post else { return [] }

    var candidates: [URL] = []
    if let fileExtension, !fileExtension.isEmpty,
      let direct = URL(string: "https://i.imgur.com/\(identifier).\(fileExtension)")
    {
      candidates.append(direct)
    }

    for ext in ["jpg", "png", "webp", "gif"] {
      if let url = URL(string: "https://i.imgur.com/\(identifier).\(ext)") {
        candidates.append(url)
      }
    }

    var seen = Set<URL>()
    return candidates.filter { seen.insert($0).inserted }
  }

  init?(url: URL) {
    guard let host = url.host?.lowercased(), host.contains("imgur.com") else {
      return nil
    }

    let pathComponents = url.pathComponents.filter { $0 != "/" }
    guard !pathComponents.isEmpty else { return nil }

    // Direct media links like i.imgur.com/abc123.jpg should still map to the post page.
    if host == "i.imgur.com" {
      let raw = Self.normalizedIdentifier(pathComponents[0])
      let parts = raw.split(separator: ".", maxSplits: 1).map(String.init)
      let identifier = parts.first ?? ""
      guard !identifier.isEmpty else { return nil }
      self.kind = .image
      self.identifier = identifier
      self.fileExtension = parts.count > 1 ? parts[1].lowercased() : nil
      return
    }

    let first = pathComponents[0].lowercased()

    if first == "a", pathComponents.count >= 2 {
      let identifier = Self.normalizedIdentifier(pathComponents[1])
      guard !identifier.isEmpty else { return nil }
      self.kind = .album
      self.identifier = identifier
      self.fileExtension = nil
      return
    }

    if first == "gallery", pathComponents.count >= 2 {
      let identifier = Self.normalizedIdentifier(pathComponents[1])
      guard !identifier.isEmpty else { return nil }
      self.kind = .gallery
      self.identifier = identifier
      self.fileExtension = nil
      return
    }

    let identifier = Self.normalizedIdentifier(pathComponents[0])
    guard !identifier.isEmpty else { return nil }
    self.kind = .post
    self.identifier = identifier
    self.fileExtension = nil
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
