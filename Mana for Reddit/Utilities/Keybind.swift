//
//  Keybind.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

/// A single keyboard shortcut binding with a description and an action.
struct Keybind {
    let key: KeyEquivalent
    let modifiers: EventModifiers
    let description: String
    let action: () -> Void

    init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = [],
        description: String,
        action: @escaping () -> Void
    ) {
        self.key = key
        self.modifiers = modifiers
        self.description = description
        self.action = action
    }

    func matches(_ keyPress: KeyPress) -> Bool {
        keyPress.key == key && keyPress.modifiers == modifiers
    }
}

extension View {
    /// Attach multiple keybinds to a view. Handled keys are consumed and do not propagate.
    func keybinds(_ keybinds: [Keybind]) -> some View {
        onKeyPress { keyPress in
            for keybind in keybinds {
                if keybind.matches(keyPress) {
                    keybind.action()
                    return .handled
                }
            }
            return .ignored
        }
    }
}
