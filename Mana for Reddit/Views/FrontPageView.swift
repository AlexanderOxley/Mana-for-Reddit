//
//  FrontPageView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct FrontPageView: View {
    @ObservedObject var viewModel: FrontPageViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
                    ContentUnavailableView(
                        "Could not load posts",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else {
                    List(viewModel.posts) { post in
                        PostRowView(post: post)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadPosts()
                    }
                }
            }
            .navigationTitle("Front Page")
        }
        .task {
            guard viewModel.posts.isEmpty else { return }
            await viewModel.loadPosts()
        }
    }
}

#Preview {
    let vm = FrontPageViewModel()
    vm.posts = [
        Post(
            id: "1",
            title: "Swift 6 concurrency guide — everything you need to know about actors and structured concurrency",
            author: "swifter99",
            subreddit: "swift",
            score: 2048,
            numComments: 87,
            url: "https://example.com",
            thumbnail: nil,
            permalink: "/r/swift/1"
        ),
        Post(
            id: "2",
            title: "I built a barebones Reddit client in SwiftUI in one afternoon",
            author: "alexo",
            subreddit: "iOSProgramming",
            score: 512,
            numComments: 33,
            url: "https://example.com",
            thumbnail: nil,
            permalink: "/r/iOSProgramming/2"
        ),
        Post(
            id: "3",
            title: "Ask HN: What are your favourite SwiftUI architecture patterns?",
            author: "hn_user",
            subreddit: "programming",
            score: 305,
            numComments: 120,
            url: "https://example.com",
            thumbnail: nil,
            permalink: "/r/programming/3"
        ),
    ]
    return FrontPageView(viewModel: vm)
}
