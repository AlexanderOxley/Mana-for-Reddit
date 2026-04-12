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
  @Published var searchText = ""
  @Published var searchResults: [Source] = []
  @Published var isSearching = false

  private let maxRecentSubreddits = 10
  private let recentSubredditsKey = "sidebar.recentSubreddits"
  private var recentSubreddits: [Source] = []
  private let transport = SidebarTransportViewModel()
  private var searchTask: Task<Void, Never>?

  init() {
    loadRecentSubreddits()
    rebuildItems()
  }

  func select(_ item: Source?) {
    selectedItem = item
  }

  func updateSearchQuery(_ query: String) {
    searchTask?.cancel()
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmed.isEmpty else {
      searchResults = []
      isSearching = false
      return
    }

    searchTask = Task {
      isSearching = true
      do {
        try await Task.sleep(nanoseconds: 250_000_000)
        let results = try await transport.searchSubreddits(query: trimmed)
        guard !Task.isCancelled else { return }
        searchResults = deduplicated(results)
      } catch {
        if Task.isCancelled { return }
        searchResults = []
      }
      isSearching = false
    }
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
    searchText = ""
    searchResults = []
  }

  var recentSuggestions: [Source] {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !trimmed.isEmpty else { return recentSubreddits }
    return recentSubreddits.filter { $0.title.lowercased().contains(trimmed) }
  }

  func clearAllRecents() {
    recentSubreddits = []
    persistRecentSubreddits()
    rebuildItems()
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

  private func deduplicated(_ sources: [Source]) -> [Source] {
    var seen = Set<String>()
    return sources.filter { source in
      if seen.contains(source.id) { return false }
      seen.insert(source.id)
      return true
    }
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
