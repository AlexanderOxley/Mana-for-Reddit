//
//  Entrypoint.swift
//  NavigationSplitView
//
/**
import SwiftUI

private enum IPadSplitStyleOption {
    case balanced
    case prominentDetail
}

struct Entrypoint: View {
    @State private var viewModel = AppViewModel()
    @State private var isLandscape = false
    @State private var iPadSplitStyle: IPadSplitStyleOption = .balanced
    
    var body: some View {
        let splitView = NavigationSplitView {
            SidebarColumnView()
        } content: {
            if let category = viewModel.selectedCategory {
                ContentColumnView(category: category)
            } else {
                Text("Select a category")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            if let item = viewModel.selectedItem {
                DetailColumnView(item: item)
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }

        let splitViewWithOrientationTracking = splitView.background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        isLandscape = geometry.size.width > geometry.size.height
                    }
                    .onChange(of: geometry.size) {
                        isLandscape = geometry.size.width > geometry.size.height
                    }
            }
        }

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if iPadSplitStyle == .balanced {
                splitViewWithOrientationTracking.navigationSplitViewStyle(.balanced)
            } else {
                splitViewWithOrientationTracking.navigationSplitViewStyle(.prominentDetail)
            }
        } else {
            splitViewWithOrientationTracking
        }
        #else
        splitViewWithOrientationTracking
        #endif
        .environment(viewModel)
        .onAppear {
            updateIPadSplitStyle()
        }
        .onChange(of: isLandscape) {
            updateIPadSplitStyle()
        }
    }

    private func updateIPadSplitStyle() {
        #if os(iOS)
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        iPadSplitStyle = isLandscape ? .balanced : .prominentDetail
        #endif
    }
}

#Preview {
    Entrypoint()
}
**/
