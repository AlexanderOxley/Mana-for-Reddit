//
//  MarkdownTextView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct MarkdownTextView: View {
  let markdown: String
  var font: Font = .body
  var lineLimit: Int? = nil

  var body: some View {
    Text(parsedText)
      .font(font)
      .lineLimit(lineLimit)
      .foregroundStyle(.primary)
      .tint(.blue)
      .textSelection(.enabled)
      .environment(
        \.openURL,
        OpenURLAction { url in
          .systemAction(url)
        }
      )
  }

  private var parsedText: AttributedString {
    let value = markdown.decodedHTMLEntities
    if let parsed = try? AttributedString(
      markdown: value,
      options: AttributedString.MarkdownParsingOptions(
        interpretedSyntax: .inlineOnlyPreservingWhitespace)
    ) {
      return parsed
    }
    return AttributedString(value)
  }
}

extension String {
  fileprivate var decodedHTMLEntities: String {
    self
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&lt;", with: "<")
      .replacingOccurrences(of: "&gt;", with: ">")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#39;", with: "'")
  }
}
