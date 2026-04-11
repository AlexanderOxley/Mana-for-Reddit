//
//  Comment.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Comment: Identifiable {
    let id: String
    let author: String
    let body: String
    let score: Int
    let depth: Int
    let replies: [Comment]

    // Memberwise init for previews and testing
    init(id: String, author: String, body: String, score: Int, depth: Int, replies: [Comment]) {
        self.id = id
        self.author = author
        self.body = body
        self.score = score
        self.depth = depth
        self.replies = replies
    }
}

extension Comment: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, author, body, score, depth, replies
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        author = (try? c.decode(String.self, forKey: .author)) ?? "[deleted]"
        body = (try? c.decode(String.self, forKey: .body)) ?? ""
        score = (try? c.decode(Int.self, forKey: .score)) ?? 0
        depth = (try? c.decode(Int.self, forKey: .depth)) ?? 0

        // Reddit returns replies as either "" (empty string) or a full Listing object
        if let listing = try? c.decode(CommentListingWrapper.self, forKey: .replies) {
            replies = listing.data.children.compactMap { $0.kind == "t1" ? $0.comment : nil }
        } else {
            replies = []
        }
    }
}

// MARK: - Shared comment decoding types (used by Comment + RedditService)

struct CommentListingWrapper: Decodable {
    let data: CommentListingData
}

struct CommentListingData: Decodable {
    let children: [CommentChild]
}

struct CommentChild: Decodable {
    let kind: String
    let comment: Comment?

    enum CodingKeys: String, CodingKey { case kind, data }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(String.self, forKey: .kind)
        // "more" kind has a different data shape — decode optionally
        comment = try? c.decode(Comment.self, forKey: .data)
    }
}
