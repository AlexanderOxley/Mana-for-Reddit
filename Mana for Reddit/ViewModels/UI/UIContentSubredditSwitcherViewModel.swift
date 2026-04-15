//
//  UIContentSubredditSwitcherViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

import Combine
import Foundation

@MainActor
final class ContentSubredditSwitcherViewModel: ObservableObject {
  @Published var isPresented = false
  @Published private(set) var focusRequestID = UUID()
  @Published var query = ""
  @Published private(set) var isSearching = false
  @Published private(set) var searchResults: [Source] = []
  @Published private(set) var recents: [Source] = []

  private let maxRecents = 3
  private let recentsKey = "contentColumn.recentSubreddits"
  private let transport = SidebarTransportViewModel()
  private var searchTask: Task<Void, Never>?

  init() {
    loadRecents()
  }

  var filteredRecents: [Source] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !trimmed.isEmpty else { return recents }
    return recents.filter { $0.title.lowercased().contains(trimmed) }
  }

  func present(prefill: String = "") {
    if !prefill.isEmpty {
      query = prefill
      updateQuery(prefill)
    }
    isPresented = true
    requestFocus()
  }

  func dismiss() {
    isPresented = false
  }

  func clearQuery() {
    searchTask?.cancel()
    query = ""
    searchResults = []
    isSearching = false
  }

  func requestFocus() {
    focusRequestID = UUID()
  }

  func updateQuery(_ newValue: String) {
    query = newValue
    searchTask?.cancel()

    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      searchResults = []
      isSearching = false
      return
    }

    searchTask = Task { [weak self] in
      guard let self else { return }
      isSearching = true
      do {
        try await Task.sleep(nanoseconds: 250_000_000)
        let results = try await transport.searchSubreddits(query: trimmed, limit: 10)
        guard !Task.isCancelled else { return }
        searchResults = deduplicated(results)
      } catch {
        if Task.isCancelled { return }
        searchResults = []
      }
      isSearching = false
    }
  }

  func rememberSelection(_ source: Source) {
    guard source.id != Source.frontPage.id else {
      dismiss()
      clearQuery()
      return
    }

    recents.removeAll { $0.id == source.id }
    recents.insert(source, at: 0)
    recents = Array(recents.prefix(maxRecents))
    persistRecents()

    dismiss()
    clearQuery()
  }

  private func deduplicated(_ sources: [Source]) -> [Source] {
    var seen = Set<String>()
    return sources.filter { source in
      if seen.contains(source.id) { return false }
      seen.insert(source.id)
      return true
    }
  }

  private func loadRecents() {
    let names = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
    recents = names.prefix(maxRecents).map { Source.subreddit($0) }
  }

  private func persistRecents() {
    let names = recents.prefix(maxRecents).map { source in
      if source.title.hasPrefix("r/") {
        return String(source.title.dropFirst(2))
      }
      return source.title
    }
    UserDefaults.standard.set(Array(names), forKey: recentsKey)
  }
}
