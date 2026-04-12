//
//  TransportSidebarColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

@MainActor
final class SidebarTransportViewModel {
  private let userAgent = "ios:com.mana.reddit:v1.0 (by /u/mana-app)"

  func searchSubreddits(query: String, limit: Int = 10) async throws -> [Source] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return [] }

    var components = URLComponents(string: "https://www.reddit.com/subreddits/search.json")
    components?.queryItems = [
      URLQueryItem(name: "q", value: trimmed),
      URLQueryItem(name: "limit", value: "\(limit)"),
      URLQueryItem(name: "include_over_18", value: "on"),
    ]

    guard let url = components?.url else {
      throw ManaRedditServiceError.unexpectedFormat
    }

    var request = URLRequest(url: url)
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse else {
      throw ManaRedditServiceError.unexpectedFormat
    }
    guard http.statusCode == 200 else {
      throw ManaRedditServiceError.invalidResponse(http.statusCode)
    }

    let listing = try JSONDecoder().decode(SubredditSearchListingDTO.self, from: data)
    let names = listing.data.children.map { $0.data.displayName }
    return names.map { Source.subreddit($0) }
  }
}

private struct SubredditSearchListingDTO: Decodable {
  let data: DataDTO

  struct DataDTO: Decodable {
    let children: [ChildDTO]
  }

  struct ChildDTO: Decodable {
    let data: SubredditDTO
  }

  struct SubredditDTO: Decodable {
    let displayName: String

    enum CodingKeys: String, CodingKey {
      case displayName = "display_name"
    }
  }
}
