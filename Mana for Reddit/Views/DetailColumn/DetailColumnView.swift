//
//  DetailColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct DetailColumnView: View {
    let item: DetailColumnItem

    var body: some View {
        CommentsView(item: item)
    }
}

#Preview {
    DetailColumnView(item: Post(
        id: "1",
        title: "Swift concurrency deep dive — actors, tasks, and async/await explained",
        author: "swifter99",
        subreddit: "swift",
        score: 2048,
        numComments: 87,
        url: "https://example.com",
        thumbnail: nil,
        permalink: "/r/swift/comments/1"
    ))
    .environmentObject(AppViewModel())
}
