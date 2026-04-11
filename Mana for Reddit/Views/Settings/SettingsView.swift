//
//  SettingsView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct InspectorSettingsView: View {
  @Binding var isShowingInspector: Bool
  @Environment(\.dismiss) private var dismiss

  @State private var username = ""
  @State private var password = ""

  var body: some View {
    NavigationStack {
      Form {
        Section("Account") {
          TextField("Username", text: $username)
          SecureField("Password", text: $password)
        }
        .disabled(true)

        Section("Status") {
          Text("Login flow placeholder")
            .foregroundStyle(.secondary)
        }

        Button("Log In") {
          print("Log in tapped")
        }
      }
      .navigationTitle("Settings")
      #if os(iOS)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", role: .cancel) {
              isShowingInspector = false
              dismiss()
            }
          }
        }
      #endif
    }
  }
}

#Preview {
  InspectorSettingsView(isShowingInspector: .constant(true))
}
