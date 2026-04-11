//
//  CommentRowView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.author)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Label("\(comment.score)", systemImage: "arrow.up")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(comment.body)
                .font(.body)
        }
        .padding(.leading, CGFloat(comment.depth) * 12)
        .padding(.vertical, 4)
    }
}

#Preview {
    CommentRowView(comment: Comment(
        id: "c1",
        author: "swifter99",
        body: "This is a great post! Really enjoyed reading through the examples.",
        score: 42,
        depth: 0,
        replies: []
    ))
    .padding()
}
