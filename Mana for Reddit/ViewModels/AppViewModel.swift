//
//  AppViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedFeed: SidebarItem? = .frontPage {
        didSet {
            selectedPost = nil
        }
    }
    @Published var selectedPost: Post?

    @Published var posts: [Post] = []
    @Published var isLoadingPosts = false
    @Published var postsErrorMessage: String?

    @Published var comments: [Comment] = []
    @Published var isLoadingComments = false
    @Published var commentsErrorMessage: String?

    private var loadedPermalink: String?

    func loadFrontPage() async {
        isLoadingPosts = true
        postsErrorMessage = nil
        do {
            posts = try await RedditService.fetchFrontPage()
        } catch {
            postsErrorMessage = error.localizedDescription
        }
        isLoadingPosts = false
    }

    func loadComments(for post: Post) async {
        guard post.permalink != loadedPermalink else { return }
        loadedPermalink = post.permalink
        isLoadingComments = true
        commentsErrorMessage = nil
        comments = []
        do {
            comments = try await RedditService.fetchComments(permalink: post.permalink)
        } catch {
            commentsErrorMessage = error.localizedDescription
        }
        isLoadingComments = false
    }
}
