//
//  PostListingDTO.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// Reddit wraps all listing responses in an envelope; this DTO maps that top-level shape.
struct PostListingDTO: Decodable {
  let data: PostListingDataDTO
}
