//
//  UISidebarColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Combine
import Foundation

@MainActor
final class SidebarColumnViewModel: ObservableObject {
  @Published var items: [Source] = Source.defaults
  @Published var selectedItem: Source? = .frontPage

  private let maxRecentSubreddits = 10
  private let recentSubredditsKey = "sidebar.recentSubreddits"
  private var recentSubreddits: [Source] = []

  init() {
    loadRecentSubreddits()
    rebuildItems()
  }

  func select(_ item: Source?) {
    guard selectedItem?.id != item?.id else { return }
    selectedItem = item
  }

  func addAndSelectSubreddit(_ source: Source) {
    guard source.id != Source.frontPage.id else {
      select(.frontPage)
      return
    }

    recentSubreddits.removeAll { $0.id == source.id }
    recentSubreddits.insert(source, at: 0)
    if recentSubreddits.count > maxRecentSubreddits {
      recentSubreddits = Array(recentSubreddits.prefix(maxRecentSubreddits))
    }

    persistRecentSubreddits()
    rebuildItems()
    selectedItem = source
  }

  var recents: [Source] {
    recentSubreddits
  }

  func removeSubreddit(_ source: Source) {
    guard source.id != Source.frontPage.id else { return }
    recentSubreddits.removeAll { $0.id == source.id }
    persistRecentSubreddits()
    rebuildItems()
    if selectedItem?.id == source.id {
      selectedItem = .frontPage
    }
  }

  private func rebuildItems() {
    items = [Source.frontPage] + recentSubreddits
  }

  private func loadRecentSubreddits() {
    let names = UserDefaults.standard.stringArray(forKey: recentSubredditsKey) ?? []
    recentSubreddits = names.prefix(maxRecentSubreddits).map { Source.subreddit($0) }
  }

  private func persistRecentSubreddits() {
    let names = recentSubreddits.prefix(maxRecentSubreddits).map { source in
      if source.title.hasPrefix("r/") {
        return String(source.title.dropFirst(2))
      }
      return source.title
    }
    UserDefaults.standard.set(Array(names), forKey: recentSubredditsKey)
  }
}
