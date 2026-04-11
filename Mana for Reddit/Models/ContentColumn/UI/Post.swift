//
//  Post.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Post: Identifiable, Decodable, Hashable, Equatable {
  let id: String
  let title: String
  let author: String
  let subreddit: String
  let score: Int
  let numComments: Int
  let url: String
  let thumbnail: String?
  let permalink: String
  let selfText: String
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

  // Custom decoder handles cases where Reddit returns `false` for hidden scores.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: PostCodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    author = try container.decode(String.self, forKey: .author)
    subreddit = try container.decode(String.self, forKey: .subreddit)
    score = (try? container.decode(Int.self, forKey: .score)) ?? 0
    numComments = (try? container.decode(Int.self, forKey: .numComments)) ?? 0
    url = (try? container.decode(String.self, forKey: .url)) ?? ""
    thumbnail = try? container.decode(String.self, forKey: .thumbnail)
    permalink = (try? container.decode(String.self, forKey: .permalink)) ?? ""
    selfText = (try? container.decode(String.self, forKey: .selfText)) ?? ""
    createdUTC = try? container.decode(Double.self, forKey: .createdUTC)
  }

  // Memberwise init for previews and testing.
  init(
    id: String,
    title: String,
    author: String,
    subreddit: String,
    score: Int,
    numComments: Int,
    url: String,
    thumbnail: String?,
    permalink: String,
    selfText: String = "",
    createdUTC: Double? = nil
  ) {
    self.id = id
    self.title = title
    self.author = author
    self.subreddit = subreddit
    self.score = score
    self.numComments = numComments
    self.url = url
    self.thumbnail = thumbnail
    self.permalink = permalink
    self.selfText = selfText
    self.createdUTC = createdUTC
  }
}
