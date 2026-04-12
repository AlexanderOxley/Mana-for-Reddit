//
//  Post.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum PostContentIntent {
  case gallery([URL])
  case video(URL)
  case image(URL)
  case text(String)
  case thirdParty(ThirdPartyEmbed)
  case externalLink(URL)
  case none
}

enum ThirdPartyProvider: String, Hashable {
  case youtube
  case twitter
  case redgifs
  case streamff
  case vimeo
  case tiktok
  case instagram
  case twitch
  case imgur
  case nytimes
  case guardian
  case bbc
  case soundcloud
  case spotify
  case other

  var displayName: String {
    switch self {
    case .youtube: return "YouTube"
    case .twitter: return "X / Twitter"
    case .redgifs: return "Redgifs"
    case .streamff: return "Streamff"
    case .vimeo: return "Vimeo"
    case .tiktok: return "TikTok"
    case .instagram: return "Instagram"
    case .twitch: return "Twitch"
    case .imgur: return "Imgur"
    case .nytimes: return "NYTimes"
    case .guardian: return "The Guardian"
    case .bbc: return "BBC"
    case .soundcloud: return "SoundCloud"
    case .spotify: return "Spotify"
    case .other: return "External Embed"
    }
  }
}

struct ThirdPartyEmbed: Hashable {
  let provider: ThirdPartyProvider
  let url: URL
  let title: String?
  let providerName: String?
}

enum PostFlairSegment: Hashable {
  case text(String)
  case emoji(url: URL, fallback: String)
}

struct Post: Identifiable, Decodable, Hashable, Equatable {
  let id: String
  let title: String
  let author: String
  let subreddit: String
  let ups: Int
  let score: Int
  let numComments: Int
  let url: String
  private let urlOverriddenByDest: String?
  let thumbnail: String?
  let permalink: String
  let selfText: String
  let createdUTC: Double?
  let over18: Bool
  let spoiler: Bool
  let domain: String
  let isSelf: Bool
  let linkFlairText: String?
  private let linkFlairSegmentsStored: [PostFlairSegment]
  let subredditNamePrefixed: String
  let authorFullname: String?
  let postHint: String?
  let isVideo: Bool
  let isPinned: Bool
  let isStickied: Bool
  let editedUTC: Double?
  private let oembedProviderName: String?
  private let oembedTitle: String?
  private let videoHLSURLString: String?
  private let videoFallbackURLString: String?
  private let previewImageURLStrings: [String]
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

  var previewImageURLs: [URL] {
    previewImageURLStrings.compactMap { URL(string: Self.normalizedURLString($0)) }
  }

  var editedDate: Date? {
    guard let editedUTC else { return nil }
    return Date(timeIntervalSince1970: editedUTC)
  }

  var relativeEditedDescription: String? {
    guard let editedDate else { return nil }
    return Self.relativeFormatter.localizedString(for: editedDate, relativeTo: Date())
  }

  var videoURL: URL? {
    // Prefer HLS because Reddit DASH fallback URLs are often video-only (no audio track).
    if let videoHLSURLString {
      return URL(string: Self.normalizedURLString(videoHLSURLString))
    }
    guard let videoFallbackURLString else { return nil }
    return URL(string: Self.normalizedURLString(videoFallbackURLString))
  }

  var imageURL: URL? {
    if !galleryImageURLs.isEmpty || videoURL != nil { return nil }

    guard let candidate = contentURL else { return nil }

    if postHint == "image" { return candidate }

    let allowed = ["jpg", "jpeg", "png", "webp", "gif"]
    if allowed.contains(candidate.pathExtension.lowercased()) {
      return candidate
    }

    return nil
  }

  var contentURL: URL? {
    let preferred = urlOverriddenByDest ?? url
    let normalized = Self.normalizedURLString(preferred)
    return URL(string: normalized)
  }

  var flairSegments: [PostFlairSegment] {
    if !linkFlairSegmentsStored.isEmpty {
      return linkFlairSegmentsStored
    }

    if let linkFlairText,
      !linkFlairText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return [.text(linkFlairText)]
    }

    return []
  }

  var isExternalLink: Bool {
    guard let host = contentURL?.host else { return false }
    return !host.hasSuffix("reddit.com") && !host.hasSuffix("redd.it")
  }

  var isPinnedOrStickied: Bool {
    isPinned || isStickied
  }

  var contentIntent: PostContentIntent {
    if !galleryImageURLs.isEmpty {
      return .gallery(galleryImageURLs)
    }

    if let videoURL {
      return .video(videoURL)
    }

    if let imageURL {
      return .image(imageURL)
    }

    if let preview = previewImageURLs.first {
      return .image(preview)
    }

    let trimmedSelfText = selfText.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedSelfText.isEmpty {
      return .text(selfText)
    }

    if let thirdPartyEmbed {
      return .thirdParty(thirdPartyEmbed)
    }

    if let contentURL, isExternalLink {
      return .externalLink(contentURL)
    }

    return .none
  }

  var thirdPartyEmbed: ThirdPartyEmbed? {
    guard let contentURL else { return nil }

    let provider = Self.detectThirdPartyProvider(
      url: contentURL,
      providerName: oembedProviderName
    )

    if provider == .other,
      oembedProviderName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    {
      return nil
    }

    return ThirdPartyEmbed(
      provider: provider,
      url: contentURL,
      title: oembedTitle,
      providerName: oembedProviderName
    )
  }

  private static func normalizedURLString(_ value: String) -> String {
    value.replacingOccurrences(of: "&amp;", with: "&")
  }

  private static func detectThirdPartyProvider(url: URL, providerName: String?)
    -> ThirdPartyProvider
  {
    let host = url.host?.lowercased() ?? ""
    let provider = providerName?.lowercased() ?? ""

    if host.contains("youtube.com") || host.contains("youtu.be") || provider.contains("youtube") {
      return .youtube
    }
    if host.contains("twitter.com") || host.contains("x.com") || provider.contains("twitter") {
      return .twitter
    }
    if host.contains("redgifs.com") || host.contains("gfycat.com") || provider.contains("redgifs") {
      return .redgifs
    }
    if host.contains("streamff.link") || provider.contains("streamff") {
      return .streamff
    }
    if host.contains("vimeo.com") || provider.contains("vimeo") {
      return .vimeo
    }
    if host.contains("tiktok.com") || provider.contains("tiktok") {
      return .tiktok
    }
    if host.contains("instagram.com") || provider.contains("instagram") {
      return .instagram
    }
    if host.contains("twitch.tv") || provider.contains("twitch") {
      return .twitch
    }
    if host.contains("imgur.com") || provider.contains("imgur") {
      return .imgur
    }
    if host.contains("nytimes.com") || provider.contains("new york times") {
      return .nytimes
    }
    if host.contains("theguardian.com") || host.contains("guardian.co.uk")
      || provider.contains("guardian")
    {
      return .guardian
    }
    if host.contains("bbc.com") || host.contains("bbc.co.uk") || provider == "bbc" {
      return .bbc
    }
    if host.contains("soundcloud.com") || provider.contains("soundcloud") {
      return .soundcloud
    }
    if host.contains("spotify.com") || provider.contains("spotify") {
      return .spotify
    }
    return .other
  }

  // Custom decoder handles cases where Reddit returns `false` for hidden scores.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: PostCodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    author = try container.decode(String.self, forKey: .author)
    subreddit = try container.decode(String.self, forKey: .subreddit)
    ups = (try? container.decode(Int.self, forKey: .ups)) ?? 0
    score = (try? container.decode(Int.self, forKey: .score)) ?? 0
    numComments = (try? container.decode(Int.self, forKey: .numComments)) ?? 0
    url = (try? container.decode(String.self, forKey: .url)) ?? ""
    urlOverriddenByDest = try? container.decode(String.self, forKey: .urlOverriddenByDest)
    thumbnail = try? container.decode(String.self, forKey: .thumbnail)
    permalink = (try? container.decode(String.self, forKey: .permalink)) ?? ""
    selfText = (try? container.decode(String.self, forKey: .selfText)) ?? ""
    createdUTC = try? container.decode(Double.self, forKey: .createdUTC)
    over18 = (try? container.decode(Bool.self, forKey: .over18)) ?? false
    spoiler = (try? container.decode(Bool.self, forKey: .spoiler)) ?? false
    domain = (try? container.decode(String.self, forKey: .domain)) ?? ""
    isSelf = (try? container.decode(Bool.self, forKey: .isSelf)) ?? false
    linkFlairText = try? container.decode(String.self, forKey: .linkFlairText)
    linkFlairSegmentsStored = Self.decodeFlairSegments(from: container)
    subredditNamePrefixed =
      (try? container.decode(String.self, forKey: .subredditNamePrefixed)) ?? "r/\(subreddit)"
    authorFullname = try? container.decode(String.self, forKey: .authorFullname)
    postHint = try? container.decode(String.self, forKey: .postHint)
    isVideo = (try? container.decode(Bool.self, forKey: .isVideo)) ?? false
    isPinned = (try? container.decode(Bool.self, forKey: .pinned)) ?? false
    isStickied = (try? container.decode(Bool.self, forKey: .stickied)) ?? false
    editedUTC = Self.decodeEditedUTC(from: container)

    let secureMedia = try? container.decode(PostMediaDTO.self, forKey: .secureMedia)
    let media = try? container.decode(PostMediaDTO.self, forKey: .media)
    let redditVideo = secureMedia?.redditVideo ?? media?.redditVideo
    let oembed = secureMedia?.oembed ?? media?.oembed
    oembedProviderName = oembed?.providerName
    oembedTitle = oembed?.title

    if let redditVideo {
      videoHLSURLString = redditVideo.hlsURL
      videoFallbackURLString = redditVideo.fallbackURL
    } else {
      videoHLSURLString = nil
      videoFallbackURLString = nil
    }

    if let preview = try? container.decode(PostPreviewDTO.self, forKey: .preview) {
      previewImageURLStrings = preview.images.compactMap { image in
        if let source = image.source?.url { return source }
        return image.resolutions.last?.url
      }
    } else {
      previewImageURLStrings = []
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
    ups: Int = 0,
    score: Int,
    numComments: Int,
    url: String,
    urlOverriddenByDest: String? = nil,
    thumbnail: String?,
    permalink: String,
    selfText: String = "",
    createdUTC: Double? = nil,
    over18: Bool = false,
    spoiler: Bool = false,
    domain: String = "",
    isSelf: Bool = false,
    linkFlairText: String? = nil,
    linkFlairSegmentsStored: [PostFlairSegment] = [],
    subredditNamePrefixed: String? = nil,
    authorFullname: String? = nil,
    postHint: String? = nil,
    isVideo: Bool = false,
    isPinned: Bool = false,
    isStickied: Bool = false,
    editedUTC: Double? = nil,
    oembedProviderName: String? = nil,
    oembedTitle: String? = nil,
    videoHLSURLString: String? = nil,
    videoFallbackURLString: String? = nil,
    previewImageURLStrings: [String] = [],
    galleryImageURLStrings: [String] = []
  ) {
    self.id = id
    self.title = title
    self.author = author
    self.subreddit = subreddit
    self.ups = ups
    self.score = score
    self.numComments = numComments
    self.url = url
    self.urlOverriddenByDest = urlOverriddenByDest
    self.thumbnail = thumbnail
    self.permalink = permalink
    self.selfText = selfText
    self.createdUTC = createdUTC
    self.over18 = over18
    self.spoiler = spoiler
    self.domain = domain
    self.isSelf = isSelf
    self.linkFlairText = linkFlairText
    self.linkFlairSegmentsStored = linkFlairSegmentsStored
    self.subredditNamePrefixed = subredditNamePrefixed ?? "r/\(subreddit)"
    self.authorFullname = authorFullname
    self.postHint = postHint
    self.isVideo = isVideo
    self.isPinned = isPinned
    self.isStickied = isStickied
    self.editedUTC = editedUTC
    self.oembedProviderName = oembedProviderName
    self.oembedTitle = oembedTitle
    self.videoHLSURLString = videoHLSURLString
    self.videoFallbackURLString = videoFallbackURLString
    self.previewImageURLStrings = previewImageURLStrings
    self.galleryImageURLStrings = galleryImageURLStrings
  }

  private static func decodeEditedUTC(from container: KeyedDecodingContainer<PostCodingKeys>)
    -> Double?
  {
    if let editedTimestamp = try? container.decode(Double.self, forKey: .edited) {
      return editedTimestamp
    }
    return nil
  }

  private static func decodeFlairSegments(from container: KeyedDecodingContainer<PostCodingKeys>)
    -> [PostFlairSegment]
  {
    guard
      let richtext = try? container.decode(
        [PostFlairRichtextItemDTO].self, forKey: .linkFlairRichtext)
    else {
      return []
    }

    return richtext.compactMap { item in
      if item.kind == "text", let text = item.text {
        return .text(text)
      }

      if item.kind == "emoji",
        let urlValue = item.url,
        let url = URL(string: Self.normalizedURLString(urlValue))
      {
        return .emoji(url: url, fallback: item.text ?? "")
      }

      return nil
    }
  }
}

private struct PostMediaDTO: Decodable {
  let redditVideo: RedditVideoDTO?
  let oembed: PostOEmbedDTO?

  enum CodingKeys: String, CodingKey {
    case redditVideo = "reddit_video"
    case oembed = "oembed"
  }
}

private struct PostOEmbedDTO: Decodable {
  let providerName: String?
  let title: String?

  enum CodingKeys: String, CodingKey {
    case providerName = "provider_name"
    case title = "title"
  }
}

private struct RedditVideoDTO: Decodable {
  let hlsURL: String?
  let fallbackURL: String?

  enum CodingKeys: String, CodingKey {
    case hlsURL = "hls_url"
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

private struct PostPreviewDTO: Decodable {
  let images: [PostPreviewImageDTO]
}

private struct PostPreviewImageDTO: Decodable {
  let source: PostMediaSourceDTO?
  let resolutions: [PostMediaSourceDTO]
}

private struct PostFlairRichtextItemDTO: Decodable {
  let kind: String
  let text: String?
  let url: String?

  enum CodingKeys: String, CodingKey {
    case kind = "e"
    case text = "t"
    case url = "u"
  }
}
