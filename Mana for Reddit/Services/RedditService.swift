//
//  RedditService.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct PostPage {
    let posts: [Post]
    let after: String?
}

struct CommentPage {
    let comments: [Comment]
    let after: String?
}

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

struct RedditService {
    private static let userAgent = "ios:com.mana.reddit:v1.0 (by /u/mana-app)"

    static func fetchFrontPage(sort: PostSort = .best, timeRange: TimeRange = .today, limit: Int = 25) async throws -> [Post] {
        let page = try await fetchFrontPagePage(sort: sort, timeRange: timeRange, after: nil, limit: limit)
        return page.posts
    }

    static func fetchFrontPagePage(sort: PostSort = .best, timeRange: TimeRange = .today, after: String?, limit: Int = 25) async throws -> PostPage {
        var components = URLComponents(string: "https://www.reddit.com\(sort.endpointPath)")
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if sort.supportsTimeRange {
            queryItems.append(URLQueryItem(name: "t", value: timeRange.apiValue))
        }
        if let after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw RedditServiceError.unexpectedFormat
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw RedditServiceError.unexpectedFormat
        }
        guard http.statusCode == 200 else {
            throw RedditServiceError.invalidResponse(http.statusCode)
        }

        let listing = try JSONDecoder().decode(Listing.self, from: data)
        let posts = listing.data.children.map { $0.data }
        return PostPage(posts: posts, after: listing.data.after)
    }

    static func fetchComments(permalink: String, sort: CommentSort = .best, timeRange: TimeRange = .today, limit: Int = 200) async throws -> [Comment] {
        let page = try await fetchCommentsPage(permalink: permalink, sort: sort, timeRange: timeRange, after: nil, limit: limit)
        return page.comments
    }

    static func fetchCommentsPage(permalink: String, sort: CommentSort = .best, timeRange: TimeRange = .today, after: String?, limit: Int = 200) async throws -> CommentPage {
        // permalink is like "/r/swift/comments/abc123/title/" — append .json
        let path = permalink.hasSuffix("/") ? permalink : permalink + "/"

        var components = URLComponents(string: "https://www.reddit.com\(path).json")
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "depth", value: "10"),
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "sort", value: sort.apiValue)
        ]
        if sort.supportsTimeRange {
            queryItems.append(URLQueryItem(name: "t", value: timeRange.apiValue))
        }
        if let after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw RedditServiceError.unexpectedFormat
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw RedditServiceError.unexpectedFormat
        }
        guard http.statusCode == 200 else {
            throw RedditServiceError.invalidResponse(http.statusCode)
        }

        // Response is a JSON array: [postListing, commentListing]
        let listings = try JSONDecoder().decode([CommentListingWrapper].self, from: data)
        guard listings.count >= 2 else { throw RedditServiceError.unexpectedFormat }
        let comments = listings[1].data.children.compactMap { $0.kind == "t1" ? $0.comment : nil }
        return CommentPage(comments: comments, after: listings[1].data.after)
    }
}

// MARK: - Private Decoding Types

private struct Listing: Decodable {
    let data: ListingData
}

private struct ListingData: Decodable {
    let children: [Child]
    let after: String?
}

private struct Child: Decodable {
    let data: Post
}
