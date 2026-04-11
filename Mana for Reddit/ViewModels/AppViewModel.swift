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
    @Published var isLoadingMorePosts = false
    @Published var hasMorePosts = true

    @Published var comments: [Comment] = []
    @Published var isLoadingComments = false
    @Published var commentsErrorMessage: String?
    @Published var isLoadingMoreComments = false
    @Published var hasMoreComments = true

    private var postsAfter: String?
    private var loadedPermalink: String?
    private var commentsAfter: String?

    func loadFrontPage() async {
        postsAfter = nil
        hasMorePosts = true
        posts = []
        isLoadingPosts = true
        postsErrorMessage = nil
        do {
            let page = try await RedditService.fetchFrontPagePage(after: nil)
            posts = page.posts
            postsAfter = page.after
            hasMorePosts = page.after != nil
        } catch {
            postsErrorMessage = error.localizedDescription
            hasMorePosts = false
        }
        isLoadingPosts = false
    }

    func loadMoreFrontPage() async {
        guard hasMorePosts, !isLoadingPosts, !isLoadingMorePosts else { return }
        guard let after = postsAfter else {
            hasMorePosts = false
            return
        }

        isLoadingMorePosts = true
        do {
            let page = try await RedditService.fetchFrontPagePage(after: after)
            let existingIDs = Set(posts.map(\.id))
            let newPosts = page.posts.filter { !existingIDs.contains($0.id) }
            posts.append(contentsOf: newPosts)
            postsAfter = page.after
            hasMorePosts = page.after != nil
        } catch {
            postsErrorMessage = error.localizedDescription
        }
        isLoadingMorePosts = false
    }

    func loadComments(for post: Post) async {
        if post.permalink == loadedPermalink, !comments.isEmpty { return }
        loadedPermalink = post.permalink
        commentsAfter = nil
        hasMoreComments = true
        isLoadingComments = true
        commentsErrorMessage = nil
        comments = []
        do {
            let page = try await RedditService.fetchCommentsPage(permalink: post.permalink, after: nil)
            comments = flattenComments(page.comments)
            commentsAfter = page.after
            hasMoreComments = page.after != nil
        } catch {
            commentsErrorMessage = error.localizedDescription
            hasMoreComments = false
        }
        isLoadingComments = false
    }

    func loadMoreComments(for post: Post) async {
        guard post.permalink == loadedPermalink else { return }
        guard hasMoreComments, !isLoadingComments, !isLoadingMoreComments else { return }
        guard let after = commentsAfter else {
            hasMoreComments = false
            return
        }

        isLoadingMoreComments = true
        do {
            let page = try await RedditService.fetchCommentsPage(permalink: post.permalink, after: after)
            let existingIDs = Set(comments.map(\.id))
            let flattenedNewComments = flattenComments(page.comments)
            let newComments = flattenedNewComments.filter { !existingIDs.contains($0.id) }
            comments.append(contentsOf: newComments)
            commentsAfter = page.after
            hasMoreComments = page.after != nil
        } catch {
            commentsErrorMessage = error.localizedDescription
        }
        isLoadingMoreComments = false
    }

    private func flattenComments(_ roots: [Comment]) -> [Comment] {
        var result: [Comment] = []

        func walk(_ comment: Comment) {
            result.append(comment)
            for reply in comment.replies {
                walk(reply)
            }
        }

        for root in roots {
            walk(root)
        }

        return result
    }
}
