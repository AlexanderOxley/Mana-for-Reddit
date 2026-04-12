//
//  TransportServices.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct TransportServices {
  private static let userAgent = "ios:com.mana.reddit:v1.0 (by /u/mana-app)"

  static func fetchPosts(
    source: Source = .frontPage,
    sort: PostSort = .best,
    timeRange: TimeRange = .today,
    after: String?,
    limit: Int = 25
  ) async throws -> (posts: [Post], after: String?) {
    var components = URLComponents(
      string: "https://www.reddit.com\(source.listingPathPrefix)\(sort.endpointPath)")
    var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
    if sort.supportsTimeRange {
      queryItems.append(URLQueryItem(name: "t", value: timeRange.apiValue))
    }
    if let after {
      queryItems.append(URLQueryItem(name: "after", value: after))
    }
    components?.queryItems = queryItems

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

    let listing = try JSONDecoder().decode(PostListingDTO.self, from: data)
    let posts = listing.data.children.map { $0.data }
    return (posts, listing.data.after)
  }

  static func fetchComments(
    permalink: String,
    sort: CommentSort = .best,
    timeRange: TimeRange = .today,
    after: String?,
    limit: Int = 200
  ) async throws -> (comments: [Comment], after: String?) {
    let path = permalink.hasSuffix("/") ? permalink : permalink + "/"

    var components = URLComponents(string: "https://www.reddit.com\(path).json")
    var queryItems = [
      URLQueryItem(name: "limit", value: "\(limit)"),
      URLQueryItem(name: "depth", value: "10"),
      URLQueryItem(name: "raw_json", value: "1"),
      URLQueryItem(name: "sort", value: sort.apiValue),
    ]
    if sort.supportsTimeRange {
      queryItems.append(URLQueryItem(name: "t", value: timeRange.apiValue))
    }
    if let after {
      queryItems.append(URLQueryItem(name: "after", value: after))
    }
    components?.queryItems = queryItems

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

    let listings = try JSONDecoder().decode([CommentListingWrapper].self, from: data)
    guard listings.count >= 2 else { throw ManaRedditServiceError.unexpectedFormat }
    let comments = listings[1].data.children.compactMap { $0.kind == "t1" ? $0.comment : nil }
    return (comments, listings[1].data.after)
  }
}
