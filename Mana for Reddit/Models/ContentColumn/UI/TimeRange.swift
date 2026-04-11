//
//  TimeRange.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum TimeRange: String, CaseIterable, Hashable {
  case now
  case today
  case thisWeek
  case thisMonth
  case thisYear
  case allTime

  var title: String {
    switch self {
    case .now: return "Now"
    case .today: return "Today"
    case .thisWeek: return "This Week"
    case .thisMonth: return "This Month"
    case .thisYear: return "This Year"
    case .allTime: return "All Time"
    }
  }

  var apiValue: String {
    switch self {
    case .now: return "hour"
    case .today: return "day"
    case .thisWeek: return "week"
    case .thisMonth: return "month"
    case .thisYear: return "year"
    case .allTime: return "all"
    }
  }
}
