//
//  PostSort.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum PostSort: String, CaseIterable, Hashable {
  case best
  case hot
  case new
  case top
  case controversial
  case rising

  var title: String {
    rawValue.capitalized
  }

  var endpointPath: String {
    switch self {
    case .best: return "/best.json"
    case .hot: return "/hot.json"
    case .new: return "/new.json"
    case .top: return "/top.json"
    case .controversial: return "/controversial.json"
    case .rising: return "/rising.json"
    }
  }

  var supportsTimeRange: Bool {
    self == .top || self == .controversial
  }
}
