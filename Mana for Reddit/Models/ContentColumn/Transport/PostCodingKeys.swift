//
//  PostCodingKeys.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// Separating coding keys from the domain model makes Reddit-specific API
// key mappings explicit and keeps Post focused on app concepts.
enum PostCodingKeys: String, CodingKey {
  case id = "id"
  case title = "title"
  case author = "author"
  case subreddit = "subreddit"
  case ups = "ups"
  case score = "score"
  case url = "url"
  case urlOverriddenByDest = "url_overridden_by_dest"
  case thumbnail = "thumbnail"
  case permalink = "permalink"
  case selfText = "selftext"
  case numComments = "num_comments"
  case createdUTC = "created_utc"
  case over18 = "over_18"
  case spoiler = "spoiler"
  case domain = "domain"
  case isSelf = "is_self"
  case linkFlairText = "link_flair_text"
  case linkFlairRichtext = "link_flair_richtext"
  case subredditNamePrefixed = "subreddit_name_prefixed"
  case authorFullname = "author_fullname"
  case postHint = "post_hint"
  case preview = "preview"
  case isVideo = "is_video"
  case media = "media"
  case secureMedia = "secure_media"
  case galleryData = "gallery_data"
  case mediaMetadata = "media_metadata"
  case pinned = "pinned"
  case stickied = "stickied"
  case edited = "edited"
}
