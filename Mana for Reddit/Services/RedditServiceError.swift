//
//  RedditServiceError.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

enum RedditServiceError: LocalizedError {
  case invalidResponse(Int)
  case unexpectedFormat

  var errorDescription: String? {
    switch self {
    case .invalidResponse(let code):
      return "Reddit returned an unexpected status code: \(code)."
    case .unexpectedFormat:
      return "Could not parse the response from Reddit."
    }
  }
}
