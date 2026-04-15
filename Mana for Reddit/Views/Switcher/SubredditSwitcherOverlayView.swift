//
//  SubredditSwitcherOverlayView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

import SwiftUI

struct SubredditSwitcherOverlayView: View {
  @ObservedObject var viewModel: ContentSubredditSwitcherViewModel
  let onSelectSource: (Source) -> Void

  var body: some View {
    ZStack(alignment: .top) {
      if viewModel.isPresented {
        Color.black.opacity(0.08)
          .ignoresSafeArea()
          .contentShape(Rectangle())
          .onTapGesture {
            viewModel.dismiss()
          }
          .transition(.opacity)

        SubredditSwitcherSheetView(viewModel: viewModel) { source in
          onSelectSource(source)
        }
        .frame(maxWidth: 520)
        .padding(.top, 12)
        .padding(.horizontal, 12)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
      }
    }
    .animation(.snappy(duration: 0.2), value: viewModel.isPresented)
  }
}

#Preview {
  let vm: ContentSubredditSwitcherViewModel = {
    let vm = ContentSubredditSwitcherViewModel()
    vm.present()
    vm.updateQuery("swift")
    return vm
  }()

  ZStack {
    List(0..<20, id: \.self) { i in
      Text("Row \\(i)")
    }

    SubredditSwitcherOverlayView(viewModel: vm) { _ in }
  }
}
