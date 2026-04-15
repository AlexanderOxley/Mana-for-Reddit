//
//  Mana_for_RedditApp.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

@main
struct Mana_for_RedditApp: App {
  var body: some Scene {
    WindowGroup {
      Entrypoint()
    }
    .commands {
      CommandMenu("Sidebar") {
        Button("Focus Sidebar") {
          NotificationCenter.default.post(name: AppCommand.focusSidebar, object: nil)
        }
        .keyboardShortcut("1", modifiers: [.command])
      }

      CommandMenu("Feed") {
        Button("Focus Feed") {
          NotificationCenter.default.post(name: AppCommand.focusFeed, object: nil)
        }
        .keyboardShortcut("2", modifiers: [.command])

        Button("Switch Subreddit") {
          NotificationCenter.default.post(name: AppCommand.openSubredditSwitcher, object: nil)
        }
        .keyboardShortcut("f", modifiers: [.command])
      }

      CommandMenu("Post") {
        Button("Focus Post") {
          NotificationCenter.default.post(name: AppCommand.focusPost, object: nil)
        }
        .keyboardShortcut("3", modifiers: [.command])

        Button("Collapse Selected Comment") {
          NotificationCenter.default.post(name: AppCommand.collapseSelectedComment, object: nil)
        }
        .keyboardShortcut(.return, modifiers: [])
      }
    }
  }
}
