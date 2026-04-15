//
//  AppCommands.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

import Foundation

enum AppCommand {
  static let focusSidebar = Notification.Name("AppCommand.focusSidebar")
  static let focusFeed = Notification.Name("AppCommand.focusFeed")
  static let focusPost = Notification.Name("AppCommand.focusPost")
  static let openSubredditSwitcher = Notification.Name("AppCommand.openSubredditSwitcher")
  static let collapseSelectedComment = Notification.Name("AppCommand.collapseSelectedComment")
}
