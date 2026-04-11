//
//  CommentSort.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum CommentSort: String, CaseIterable, Hashable {
  case best
  case top
  case new
  case controversial
  case old

  var title: String {
    rawValue.capitalized
  }

  var apiValue: String {
    switch self {
    case .best: return "confidence"
    case .top: return "top"
    case .new: return "new"
    case .controversial: return "controversial"
    case .old: return "old"
    }
  }

  var supportsTimeRange: Bool {
    self == .top || self == .controversial
  }
}
