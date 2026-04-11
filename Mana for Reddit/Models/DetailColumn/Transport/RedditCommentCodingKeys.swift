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
  case score = "score"
  case depth = "depth"
  case replies = "replies"
  case createdUTC = "created_utc"
}
