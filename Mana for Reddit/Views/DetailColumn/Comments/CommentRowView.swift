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

  private var metaBadges: [String] {
    var badges: [String] = []
    if comment.gilded > 0 { badges.append("Gilded x\(comment.gilded)") }
    if comment.relativeEditedDescription != nil { badges.append("Edited") }
    if comment.stickied { badges.append("Pinned") }
    if comment.controversiality > 0 { badges.append("Controversial") }
    if let distinguished = comment.distinguished,
      !distinguished.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      badges.append(distinguished.capitalized)
    }
    return badges
  }

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
              comment.relativeEditedDescription.map { "edited \($0)" },
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
          if let authorFlairText = comment.authorFlairText,
            !authorFlairText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          {
            Text(authorFlairText)
              .font(.caption2)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(.quaternary, in: Capsule())
          }
          if let relativeAge = comment.relativeCreatedDescription {
            Text(relativeAge)
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          ForEach(metaBadges, id: \.self) { badge in
            Text(badge)
              .font(.caption2)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(.quaternary, in: Capsule())
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

#Preview("Normal") {
  CommentRowView(
    comment: Comment(
      id: "c1",
      author: "swifter99",
      body: "This is a great post! Really enjoyed reading through the examples.",
      ups: 42,
      score: 42,
      editedUTC: nil,
      gilded: 0,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c1",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: [],
      createdUTC: Date().addingTimeInterval(-3200).timeIntervalSince1970
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Collapsed") {
  CommentRowView(
    comment: Comment(
      id: "c2",
      author: "alexo",
      body: "Collapsed body preview text.",
      ups: 15,
      score: 15,
      editedUTC: Date().addingTimeInterval(-1800).timeIntervalSince1970,
      gilded: 0,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c2",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 1,
      replies: [],
      createdUTC: Date().addingTimeInterval(-7200).timeIntervalSince1970
    ),
    isCollapsed: true,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Pinned + Distinguished + Controversial") {
  CommentRowView(
    comment: Comment(
      id: "c3",
      author: "mod_team",
      body: "Please keep discussion civil and on-topic.",
      ups: 3,
      score: 3,
      editedUTC: nil,
      gilded: 0,
      distinguished: "moderator",
      stickied: true,
      permalink: "/r/swift/comments/c3",
      controversiality: 1,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: [],
      createdUTC: Date().addingTimeInterval(-18000).timeIntervalSince1970
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Author Flair") {
  CommentRowView(
    comment: Comment(
      id: "c7",
      author: "team_member",
      authorFlairText: "Swift Team",
      body: "Author flair now shows next to the username.",
      ups: 87,
      score: 87,
      editedUTC: nil,
      gilded: 0,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c7",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: [],
      createdUTC: Date().addingTimeInterval(-5000).timeIntervalSince1970
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Gilded + Edited") {
  CommentRowView(
    comment: Comment(
      id: "c4",
      author: "awardwinner",
      body: "Updated with benchmarks and references.",
      ups: 256,
      score: 256,
      editedUTC: Date().addingTimeInterval(-900).timeIntervalSince1970,
      gilded: 2,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c4",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: [],
      createdUTC: Date().addingTimeInterval(-8600).timeIntervalSince1970
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Preview Image Link") {
  CommentRowView(
    comment: Comment(
      id: "c5",
      author: "imgposter",
      body: "Here is the screenshot: https://preview.redd.it/example123.png",
      ups: 74,
      score: 74,
      editedUTC: nil,
      gilded: 0,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c5",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: []
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}

#Preview("Giphy Link") {
  CommentRowView(
    comment: Comment(
      id: "c6",
      author: "giflord",
      body: "Reaction gif https://giphy.com/gifs/funny-cat-3oriO0OEd9QIDdllqo",
      ups: 99,
      score: 99,
      editedUTC: nil,
      gilded: 0,
      distinguished: nil,
      stickied: false,
      permalink: "/r/swift/comments/c6",
      controversiality: 0,
      parentID: nil,
      linkID: nil,
      depth: 0,
      replies: []
    ),
    isCollapsed: false,
    onToggleCollapse: {}
  )
  .padding()
}
