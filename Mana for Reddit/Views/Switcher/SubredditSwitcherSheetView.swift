//
//  SubredditSwitcherSheetView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

import SwiftUI

struct SubredditSwitcherSheetView: View {
  @ObservedObject var viewModel: ContentSubredditSwitcherViewModel
  let onSelectSource: (Source) -> Void

  @FocusState private var isSearchFocused: Bool
  @State private var selectedSourceID: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)

        TextField(
          "Search subreddits",
          text: Binding(
            get: { viewModel.query },
            set: { viewModel.updateQuery($0) }
          )
        )
        .autocorrectionDisabled()
        .focused($isSearchFocused)

        if !viewModel.query.isEmpty {
          Button {
            viewModel.clearQuery()
            viewModel.requestFocus()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.secondary)
          }
          .buttonStyle(.plain)
        }

        Button {
          viewModel.dismiss()
        } label: {
          Image(systemName: "chevron.up")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
      }

      Divider()

      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          sectionTitle("General")

          sourceButton(
            title: Source.frontPage.title,
            systemImage: Source.frontPage.icon,
            role: .general,
            isSelected: selectedSourceID == Source.frontPage.id
          ) {
            onSelectSource(.frontPage)
          }

          if !viewModel.filteredRecents.isEmpty {
            sectionTitle("Recent")
            ForEach(viewModel.filteredRecents) { source in
              sourceButton(
                title: source.title,
                systemImage: "clock",
                role: .recent,
                isSelected: selectedSourceID == source.id
              ) {
                onSelectSource(source)
              }
            }
          }

          if viewModel.isSearching {
            HStack(spacing: 8) {
              ProgressView()
              Text("Searching…")
                .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding(.vertical, 4)
          }

          if !viewModel.searchResults.isEmpty {
            sectionTitle("Reddit")
            ForEach(viewModel.searchResults) { source in
              sourceButton(
                title: source.title,
                systemImage: source.icon,
                role: .reddit,
                isSelected: selectedSourceID == source.id
              ) {
                onSelectSource(source)
              }
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxHeight: 280)
    }
    .padding(12)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(.separator.opacity(0.35), lineWidth: 1)
    }
    #if os(macOS)
      .onKeyPress(.escape) {
        viewModel.dismiss()
        return .handled
      }
      .onKeyPress(.upArrow) {
        moveSelection(by: -1)
        return .handled
      }
      .onKeyPress(.downArrow) {
        moveSelection(by: 1)
        return .handled
      }
      .onKeyPress(.return) {
        confirmSelection()
        return .handled
      }
    #endif
    .onAppear {
      Task { @MainActor in
        await Task.yield()
        isSearchFocused = true
        syncSelection()
      }
    }
    .onChange(of: viewModel.focusRequestID) { _, _ in
      Task { @MainActor in
        await Task.yield()
        isSearchFocused = true
        syncSelection()
      }
    }
    .onChange(of: viewModel.query) { _, _ in
      syncSelection()
    }
    .onChange(of: viewModel.searchResults) { _, _ in
      syncSelection()
    }
    .onChange(of: viewModel.filteredRecents) { _, _ in
      syncSelection()
    }
  }

  @ViewBuilder
  private func sectionTitle(_ text: String) -> some View {
    Text(text)
      .font(.caption)
      .foregroundStyle(.secondary)
      .textCase(.uppercase)
      .padding(.top, 4)
  }

  @ViewBuilder
  private func sourceButton(
    title: String,
    systemImage: String,
    role: SourceRowRole,
    isSelected: Bool,
    action: @escaping () -> Void
  )
    -> some View
  {
    Button(action: action) {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .foregroundStyle(iconColor(for: role))
        Text(title)
          .lineLimit(1)
        Spacer(minLength: 0)
      }
      .padding(.vertical, 4)
      .padding(.horizontal, 6)
      .background {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .fill(isSelected ? Color.accentColor.opacity(0.18) : .clear)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private var selectionCandidates: [Source] {
    var ordered: [Source] = [Source.frontPage]
    ordered.append(contentsOf: viewModel.filteredRecents)
    ordered.append(contentsOf: viewModel.searchResults)

    var seen = Set<String>()
    return ordered.filter { source in
      seen.insert(source.id).inserted
    }
  }

  private func syncSelection() {
    let candidates = selectionCandidates
    guard !candidates.isEmpty else {
      selectedSourceID = nil
      return
    }

    if let selectedSourceID,
      candidates.contains(where: { $0.id == selectedSourceID })
    {
      return
    }

    selectedSourceID = candidates.first?.id
  }

  private func moveSelection(by delta: Int) {
    let candidates = selectionCandidates
    guard !candidates.isEmpty else {
      selectedSourceID = nil
      return
    }

    guard let selectedSourceID,
      let currentIndex = candidates.firstIndex(where: { $0.id == selectedSourceID })
    else {
      self.selectedSourceID = candidates.first?.id
      return
    }

    let nextIndex = max(0, min(candidates.count - 1, currentIndex + delta))
    self.selectedSourceID = candidates[nextIndex].id
  }

  private func confirmSelection() {
    let candidates = selectionCandidates
    guard !candidates.isEmpty else { return }

    if let selectedSourceID,
      let selected = candidates.first(where: { $0.id == selectedSourceID })
    {
      onSelectSource(selected)
      return
    }

    if let first = candidates.first {
      onSelectSource(first)
    }
  }

  private func iconColor(for role: SourceRowRole) -> Color {
    switch role {
    case .general: return .secondary
    case .recent: return .secondary
    case .reddit: return .accentColor
    }
  }
}

private enum SourceRowRole {
  case general
  case recent
  case reddit
}

#Preview {
  let vm: ContentSubredditSwitcherViewModel = {
    let vm = ContentSubredditSwitcherViewModel()
    vm.present()
    vm.updateQuery("swift")
    return vm
  }()

  SubredditSwitcherSheetView(viewModel: vm) { _ in }
    .padding()
}
