//
//  SubredditSwitcherButtonView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

import SwiftUI

struct SubredditSwitcherButtonView: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        Text(title)
          .font(.headline)
          .lineLimit(1)
        Image(systemName: "chevron.down")
          .font(.caption2.weight(.semibold))
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Switch subreddit")
  }
}

#Preview {
  NavigationStack {
    SubredditSwitcherButtonView(title: "r/swift") {}
      .padding()
  }
}
