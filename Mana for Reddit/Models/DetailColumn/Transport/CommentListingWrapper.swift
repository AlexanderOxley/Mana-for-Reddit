//
//  CommentListingWrapper.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

// Reddit comment APIs wrap payloads in "listing" envelopes; this DTO maps that
// transport shape so Comment decoding can stay focused on domain fields.
struct CommentListingWrapper: Decodable {
  let data: CommentListingData
}
