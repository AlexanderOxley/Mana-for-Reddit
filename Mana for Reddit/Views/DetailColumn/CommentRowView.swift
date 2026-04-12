//
//  CommentRowView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct CommentRowView: View {
  let comment: Comment
  let isCollapsed: Bool
  let onToggleCollapse: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Button(action: onToggleCollapse) {
          Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)

        if isCollapsed {
          Text(
            [
              "Collapsed:",
              comment.author,
              comment.relativeCreatedDescription,
              "\(comment.score)",
            ]
            .compactMap { $0 }
            .joined(separator: " ")
          )
          .font(.caption)
          .foregroundStyle(.secondary)
          Spacer()
        } else {
          Text(comment.author)
            .font(.caption)
            .fontWeight(.semibold)
          if let relativeAge = comment.relativeCreatedDescription {
            Text(relativeAge)
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Label("\(comment.score)", systemImage: "arrow.up")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }
      if !isCollapsed {
        MarkdownTextView(markdown: comment.body, font: .body)

        if let previewImageURL = comment.previewImageURL {
          DetailPostImageView(imageURL: previewImageURL)
            .frame(minHeight: 180)
        } else if let giphyGIFURL = comment.giphyGIFURL {
          CommentGIFView(gifURL: giphyGIFURL)
        }
      }
    }
    .padding(.leading, CGFloat(comment.depth) * 12)
    .padding(.vertical, 4)
    .contentShape(Rectangle())
    .onTapGesture(count: 2, perform: onToggleCollapse)
  }
}

#Preview {
  CommentRowView(
    comment: Comment(
      id: "c1",
      author: "swifter99",
      body: "This is a great post! Really enjoyed reading through the examples.",
      score: 42,
      depth: 0,
      replies: []
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}
