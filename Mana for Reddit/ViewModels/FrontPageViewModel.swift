//
//  FrontPageViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation
import Combine

@MainActor
class FrontPageViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await RedditService.fetchFrontPage()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
