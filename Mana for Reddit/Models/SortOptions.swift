//
//  SortOptions.swift
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
        case .now:
            return "Now"
        case .today:
            return "Today"
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .thisYear:
            return "This Year"
        case .allTime:
            return "All Time"
        }
    }

    var apiValue: String {
        switch self {
        case .now:
            return "hour"
        case .today:
            return "day"
        case .thisWeek:
            return "week"
        case .thisMonth:
            return "month"
        case .thisYear:
            return "year"
        case .allTime:
            return "all"
        }
    }
}

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
        case .best:
            return "/best.json"
        case .hot:
            return "/hot.json"
        case .new:
            return "/new.json"
        case .top:
            return "/top.json"
        case .controversial:
            return "/controversial.json"
        case .rising:
            return "/rising.json"
        }
    }

    var supportsTimeRange: Bool {
        self == .top || self == .controversial
    }
}

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
        case .best:
            return "confidence"
        case .top:
            return "top"
        case .new:
            return "new"
        case .controversial:
            return "controversial"
        case .old:
            return "old"
        }
    }

    var supportsTimeRange: Bool {
        self == .top || self == .controversial
    }
}
