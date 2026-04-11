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
  case score = "score"
  case url = "url"
  case thumbnail = "thumbnail"
  case permalink = "permalink"
  case selfText = "selftext"
  case numComments = "num_comments"
  case createdUTC = "created_utc"
  case postHint = "post_hint"
  case isVideo = "is_video"
  case media = "media"
  case galleryData = "gallery_data"
  case mediaMetadata = "media_metadata"
}
