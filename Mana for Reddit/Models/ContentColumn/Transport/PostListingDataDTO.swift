//
//  PostListingDataDTO.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct PostListingDataDTO: Decodable {
  let children: [PostChildDTO]
  let after: String?
}
