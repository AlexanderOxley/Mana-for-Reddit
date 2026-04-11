//
//  SidebarColumnView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 11.04.2026.
//

import SwiftUI

struct SidebarColumnView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        List(SidebarItem.allCases, selection: $viewModel.selectedFeed) { item in
            Label(item.rawValue, systemImage: item.icon)
                .tag(item)
        }
        .navigationTitle("Mana")
    }
}

#Preview {
    NavigationStack {
        SidebarColumnView()
    }
    .environmentObject(AppViewModel())
}
