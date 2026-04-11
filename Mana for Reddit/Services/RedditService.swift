//
//  RedditService.swift
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

struct RedditService {
    private static let userAgent = "ios:com.mana.reddit:v1.0 (by /u/mana-app)"

    static func fetchFrontPage(limit: Int = 25) async throws -> [Post] {
        guard let url = URL(string: "https://www.reddit.com/.json?limit=\(limit)") else {
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
        return listing.data.children.map { $0.data }
    }
}

// MARK: - Private Decoding Types

private struct Listing: Decodable {
    let data: ListingData
}

private struct ListingData: Decodable {
    let children: [Child]
}

private struct Child: Decodable {
    let data: Post
}
