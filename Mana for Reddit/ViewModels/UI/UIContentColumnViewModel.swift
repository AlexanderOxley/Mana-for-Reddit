//
//  UIContentColumnViewModel.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Combine
import Foundation

@MainActor
final class ContentColumnViewModel: ObservableObject {
  @Published var source: Source
  @Published var sort: PostSort = .best
  @Published var timeRange: TimeRange = .today

  @Published var posts: [Post] = []
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var errorMessage: String?
  @Published var hasMore = true

  @Published var searchText = ""
  @Published var searchResults: [Post] = []
  @Published var isSearchActive = false

  var displayedPosts: [Post] { isSearchActive ? searchResults : posts }

  private var transport = PostTransportViewModel()
  private var loadTask: Task<[Post], Error>?
  private var loadTaskID: UUID?
  private var searchTask: Task<Void, Never>?

  init(source: Source) {
    self.source = source
  }

  func setSource(_ source: Source) {
    guard self.source.id != source.id else { return }
    cancelLoad()
    self.source = source
    reset()
  }

  func load(refresh: Bool = false) async {
    if refresh {
      cancelLoad()
      reset()
    }

    let isInitialLoad = posts.isEmpty

    if isInitialLoad {
      guard !isLoading else { return }
      isLoading = true
    } else {
      guard hasMore, !isLoading, !isLoadingMore else { return }
      isLoadingMore = true
    }

    let loadID = UUID()
    loadTaskID = loadID

    defer {
      if loadTaskID == loadID {
        loadTask = nil
        loadTaskID = nil
        isLoading = false
        isLoadingMore = false
      }
    }

    do {
      let source = source
      let sort = sort
      let timeRange = timeRange
      let loadTask = Task { [transport] in
        try await transport.fetch(source: source, sort: sort, timeRange: timeRange)
      }
      self.loadTask = loadTask

      let fetched = try await loadTask.value
      guard !Task.isCancelled else { return }

      if isInitialLoad {
        posts = fetched
      } else {
        let existingIDs = Set(posts.map(\.id))
        posts.append(contentsOf: fetched.filter { !existingIDs.contains($0.id) })
      }

      hasMore = transport.after != nil
      errorMessage = nil
    } catch is CancellationError {
      return
    } catch {
      errorMessage = error.localizedDescription
      if isInitialLoad { hasMore = false }
    }
  }

  func updateSearchQuery(_ query: String) {
    searchTask?.cancel()
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmed.isEmpty else {
      isSearchActive = false
      searchResults = []
      return
    }

    searchTask = Task {
      isSearchActive = true
      isLoading = true
      do {
        try await Task.sleep(nanoseconds: 350_000_000)
        guard !Task.isCancelled else { return }
        let transport = PostTransportViewModel()
        let results = try await transport.search(query: trimmed, source: source)
        guard !Task.isCancelled else { return }
        searchResults = results
      } catch {
        if Task.isCancelled { return }
        searchResults = []
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }

  private func cancelLoad() {
    loadTask?.cancel()
    loadTask = nil
    loadTaskID = nil
    isLoading = false
    isLoadingMore = false
  }

  private func reset() {
    transport.reset()
    posts = []
    hasMore = true
    errorMessage = nil
  }
}
