//
//  DetailPostImageView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 12.04.2026.
//

import SwiftUI

struct DetailPostImageView: View {
  let imageURL: URL

  var body: some View {
    AsyncImage(url: imageURL) { phase in
      switch phase {
      case .empty:
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 220)
      case .success(let image):
        image
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      case .failure:
        ContentUnavailableView(
          "Image unavailable",
          systemImage: "photo",
          description: Text("The image could not be loaded.")
        )
      @unknown default:
        EmptyView()
      }
    }
  }
}

#Preview {
  List {
    Section("Image") {
      DetailPostImageView(imageURL: URL(string: "https://picsum.photos/800/450")!)
    }
  }
}
