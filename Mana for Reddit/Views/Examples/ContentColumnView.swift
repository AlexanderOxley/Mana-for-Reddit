//
//  ContentColumnView.swift
//  NavigationSplitView
//
/**
import SwiftUI

struct ContentColumnView: View {
    let category: Category
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText = ""

    private var filteredItems: [Item] {
        if searchText.isEmpty { return category.items }
        return category.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        List(filteredItems, selection: $viewModel.selectedItem) { item in
            Text(item.name)
                .tag(item)
        }
        .navigationTitle(category.name)
        .searchable(text: $searchText, prompt: "Search \(category.name)")
        .onChange(of: category.id) {
            searchText = ""
        }
    }
}

#Preview {
    NavigationStack {
        ContentColumnView(
            category: Category(
                name: "Books",
                items: [
                    Item(name: "Swift", description: ""),
                    Item(name: "SwiftUI", description: "")
                ]
            )
        )
    }
    .environment(AppViewModel())
}
**/
