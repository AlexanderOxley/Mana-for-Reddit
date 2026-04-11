//
//  Post.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Post: Identifiable, Decodable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let score: Int
    let numComments: Int
    let url: String
    let thumbnail: String?
    let permalink: String

    enum CodingKeys: String, CodingKey {
        case id, title, author, subreddit, score, url, thumbnail, permalink
        case numComments = "num_comments"
    }

    // Custom decoder handles cases where Reddit returns `false` for hidden scores
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        subreddit = try container.decode(String.self, forKey: .subreddit)
        score = (try? container.decode(Int.self, forKey: .score)) ?? 0
        numComments = (try? container.decode(Int.self, forKey: .numComments)) ?? 0
        url = (try? container.decode(String.self, forKey: .url)) ?? ""
        thumbnail = try? container.decode(String.self, forKey: .thumbnail)
        permalink = (try? container.decode(String.self, forKey: .permalink)) ?? ""
    }

    // Memberwise init for previews and testing
    init(
        id: String,
        title: String,
        author: String,
        subreddit: String,
        score: Int,
        numComments: Int,
        url: String,
        thumbnail: String?,
        permalink: String
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.subreddit = subreddit
        self.score = score
        self.numComments = numComments
        self.url = url
        self.thumbnail = thumbnail
        self.permalink = permalink
    }
}
