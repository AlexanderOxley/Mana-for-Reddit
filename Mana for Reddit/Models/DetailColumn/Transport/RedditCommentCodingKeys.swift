//
//  RedditCommentCodingKeys.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// This enum is separated from `Comment` to keep the model focused on domain data
// while making Reddit-specific JSON key mappings explicit.
enum RedditCommentCodingKeys: String, CodingKey {
  case id = "id"
  case author = "author"
  case body = "body"
  case ups = "ups"
  case score = "score"
  case edited = "edited"
  case gilded = "gilded"
  case distinguished = "distinguished"
  case stickied = "stickied"
  case permalink = "permalink"
  case controversiality = "controversiality"
  case parentID = "parent_id"
  case linkID = "link_id"
  case depth = "depth"
  case replies = "replies"
  case createdUTC = "created_utc"
}
