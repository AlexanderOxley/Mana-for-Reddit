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
  let postHint: String?
  let isVideo: Bool
  private let videoFallbackURLString: String?
  private let galleryImageURLStrings: [String]

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

  var galleryImageURLs: [URL] {
    galleryImageURLStrings.compactMap { URL(string: Self.normalizedURLString($0)) }
  }

  var videoURL: URL? {
    guard let videoFallbackURLString else { return nil }
    return URL(string: Self.normalizedURLString(videoFallbackURLString))
  }

  var imageURL: URL? {
    if !galleryImageURLs.isEmpty || videoURL != nil { return nil }

    let normalized = Self.normalizedURLString(url)
    guard let candidate = URL(string: normalized) else { return nil }

    if postHint == "image" { return candidate }

    let allowed = ["jpg", "jpeg", "png", "webp", "gif"]
    if allowed.contains(candidate.pathExtension.lowercased()) {
      return candidate
    }

    return nil
  }

  private static func normalizedURLString(_ value: String) -> String {
    value.replacingOccurrences(of: "&amp;", with: "&")
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
    postHint = try? container.decode(String.self, forKey: .postHint)
    isVideo = (try? container.decode(Bool.self, forKey: .isVideo)) ?? false

    if let media = try? container.decode(PostMediaDTO.self, forKey: .media),
      let fallback = media.redditVideo?.fallbackURL
    {
      videoFallbackURLString = fallback
    } else {
      videoFallbackURLString = nil
    }

    if let galleryData = try? container.decode(PostGalleryDataDTO.self, forKey: .galleryData),
      let mediaMetadata = try? container.decode(
        [String: PostMediaMetadataDTO].self, forKey: .mediaMetadata)
    {
      galleryImageURLStrings = galleryData.items.compactMap { item in
        mediaMetadata[item.mediaID]?.source?.url
      }
    } else {
      galleryImageURLStrings = []
    }
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
    createdUTC: Double? = nil,
    postHint: String? = nil,
    isVideo: Bool = false,
    videoFallbackURLString: String? = nil,
    galleryImageURLStrings: [String] = []
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
    self.postHint = postHint
    self.isVideo = isVideo
    self.videoFallbackURLString = videoFallbackURLString
    self.galleryImageURLStrings = galleryImageURLStrings
  }
}

private struct PostMediaDTO: Decodable {
  let redditVideo: RedditVideoDTO?

  enum CodingKeys: String, CodingKey {
    case redditVideo = "reddit_video"
  }
}

private struct RedditVideoDTO: Decodable {
  let fallbackURL: String?

  enum CodingKeys: String, CodingKey {
    case fallbackURL = "fallback_url"
  }
}

private struct PostGalleryDataDTO: Decodable {
  let items: [PostGalleryItemDTO]
}

private struct PostGalleryItemDTO: Decodable {
  let mediaID: String

  enum CodingKeys: String, CodingKey {
    case mediaID = "media_id"
  }
}

private struct PostMediaMetadataDTO: Decodable {
  let source: PostMediaSourceDTO?

  enum CodingKeys: String, CodingKey {
    case source = "s"
  }
}

private struct PostMediaSourceDTO: Decodable {
  let url: String?

  enum CodingKeys: String, CodingKey {
    case url = "u"
  }
}
