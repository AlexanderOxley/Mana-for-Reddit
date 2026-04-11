//
//  DetailPostGalleryView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct DetailPostGalleryView: View {
  let imageURLs: [URL]

  var body: some View {
    TabView {
      ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
        VStack(alignment: .leading, spacing: 8) {
          DetailPostImageView(imageURL: imageURL)
          Text("Image \(index + 1) of \(imageURLs.count)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 4)
      }
    }
    #if os(iOS)
      .tabViewStyle(.page)
    #else
      .tabViewStyle(.automatic)
    #endif
    .frame(minHeight: 280)
  }
}

#Preview {
  List {
    Section("Gallery") {
      DetailPostGalleryView(
        imageURLs: [
          URL(string: "https://picsum.photos/900/500?1")!,
          URL(string: "https://picsum.photos/900/500?2")!,
          URL(string: "https://picsum.photos/900/500?3")!,
        ])
    }
  }
}
