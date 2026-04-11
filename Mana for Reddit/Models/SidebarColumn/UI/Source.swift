//
//  Source.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import Foundation

struct Source: Identifiable, Hashable {
  let id: String
  let title: String
  let icon: String

  static let frontPage = Source(
    id: "front-page",
    title: "Front Page",
    icon: "house.fill"
  )

  static let defaults: [Source] = [.frontPage]
}
