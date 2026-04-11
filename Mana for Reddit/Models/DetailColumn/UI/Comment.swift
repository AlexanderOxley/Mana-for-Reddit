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
