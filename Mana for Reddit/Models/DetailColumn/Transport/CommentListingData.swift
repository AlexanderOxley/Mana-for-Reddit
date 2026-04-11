//
//  CommentListingData.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// Reddit nests comments under data.children and uses `after` for pagination.
struct CommentListingData: Decodable {
  let children: [CommentChild]
  let after: String?
}
