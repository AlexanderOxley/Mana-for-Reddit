//
//  SidebarColumnView.swift
//  NavigationSplitView
//
/**
import SwiftUI

struct SidebarColumnView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        List(sampleCategories, selection: $viewModel.selectedCategory) { category in
            Text(category.name)
                .tag(category)
        }
        .navigationTitle("Categories")
    }
}

#Preview {
    NavigationStack {
        SidebarColumnView()
    }
    .environment(AppViewModel())
}
**/
