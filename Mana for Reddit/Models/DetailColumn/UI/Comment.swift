//
//  Comment.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Comment: Identifiable, Decodable {
  let id: String
  let author: String
  let body: String
  let score: Int
  let depth: Int
  let replies: [Comment]
  let createdUTC: Double?

  private static let relativeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
  }()

  var createdDate: Date? {
    guard let createdUTC else { return nil }
    return Date(timeIntervalSince1970: createdUTC)
  }

  var relativeCreatedDescription: String? {
    guard let createdDate else { return nil }
    return Self.relativeFormatter.localizedString(for: createdDate, relativeTo: Date())
  }

  var previewImageURL: URL? {
    guard let url = firstDetectedURL else { return nil }
    guard let host = url.host?.lowercased(), host.hasSuffix("preview.redd.it") else { return nil }
    return url
  }

  var giphyGIFURL: URL? {
    guard let url = firstDetectedURL else { return nil }
    guard let host = url.host?.lowercased() else { return nil }

    if (host.contains("i.giphy.com") || host.contains("media.giphy.com"))
      && url.path.lowercased().hasSuffix(".gif")
    {
      return url
    }

    guard host.hasSuffix("giphy.com") else { return nil }

    let components = url.path.split(separator: "/")
    if let mediaIndex = components.firstIndex(of: "media"), components.count > mediaIndex + 1 {
      let id = String(components[mediaIndex + 1])
      return URL(string: "https://i.giphy.com/\(id).gif")
    }

    if let last = components.last {
      let value = String(last)
      if let id = value.split(separator: "-").last, !id.isEmpty {
        return URL(string: "https://i.giphy.com/\(id).gif")
      }
    }

    return nil
  }

  private var firstDetectedURL: URL? {
    let range = NSRange(body.startIndex..<body.endIndex, in: body)
    guard let match = Self.urlDetector.firstMatch(in: body, options: [], range: range) else {
      return nil
    }
    guard let urlRange = Range(match.range, in: body) else { return nil }
    return URL(string: String(body[urlRange]))
  }

  private static let urlDetector: NSDataDetector = {
    // Safe to force-try with a fixed, framework-provided checking type.
    try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
  }()

  // This init is for previews/tests when constructing comments manually.
  init(
    id: String,
    author: String,
    body: String,
    score: Int,
    depth: Int,
    replies: [Comment],
    createdUTC: Double? = nil
  ) {
    self.id = id
    self.author = author
    self.body = body
    self.score = score
    self.depth = depth
    self.replies = replies
    self.createdUTC = createdUTC
  }

  // Reddit may return non-standard values for some fields; decode defensively.
  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: RedditCommentCodingKeys.self)
    id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
    author = (try? c.decode(String.self, forKey: .author)) ?? "[deleted]"
    body = (try? c.decode(String.self, forKey: .body)) ?? ""
    score = (try? c.decode(Int.self, forKey: .score)) ?? 0
    depth = (try? c.decode(Int.self, forKey: .depth)) ?? 0
    createdUTC = try? c.decode(Double.self, forKey: .createdUTC)

    // Reddit returns replies as either "" (empty string) or a full listing object.
    if let listing = try? c.decode(CommentListingWrapper.self, forKey: .replies) {
      replies = listing.data.children.compactMap { $0.kind == "t1" ? $0.comment : nil }
    } else {
      replies = []
    }
  }
}
