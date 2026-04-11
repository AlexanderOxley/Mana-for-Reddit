//
//  CommentChild.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// Each listing child can be a real comment (`t1`) or another kind such as
// `more`; this DTO captures kind + optional comment payload safely.
struct CommentChild: Decodable {
  let kind: String
  let comment: Comment?

  enum CodingKeys: String, CodingKey { case kind, data }

  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    kind = try c.decode(String.self, forKey: .kind)
    // "more" kind has a different data shape — decode optionally.
    comment = try? c.decode(Comment.self, forKey: .data)
  }
}
