//
//  SortHeaderView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 14.04.2026.
//

import SwiftUI

struct SortToolbarContent<Option: Hashable>: ToolbarContent {
  let title: String
  let options: [Option]
  let label: (Option) -> String
  @Binding var selection: Option
  let showTimeRange: Bool
  @Binding var timeRange: TimeRange

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .primaryAction) {
      Menu {
        ForEach(options, id: \.self) { option in
          Button {
            selection = option
          } label: {
            if option == selection {
              Label(label(option), systemImage: "checkmark")
            } else {
              Text(label(option))
            }
          }
        }
      } label: {
        Label(label(selection), systemImage: "arrow.up.arrow.down.circle")
      }
      .accessibilityLabel(title)

      if showTimeRange {
        Menu {
          ForEach(TimeRange.allCases, id: \.self) { range in
            Button {
              timeRange = range
            } label: {
              if range == timeRange {
                Label(range.title, systemImage: "checkmark")
              } else {
                Text(range.title)
              }
            }
          }
        } label: {
          Label(timeRange.title, systemImage: "calendar")
        }
        .accessibilityLabel("Time range")
      }
    }
  }
}

#Preview {
  @Previewable @State var sort = PostSort.best
  @Previewable @State var timeRange = TimeRange.today

  NavigationStack {
    Text("Sort Toolbar Preview")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbar {
        SortToolbarContent(
          title: "Posts",
          options: PostSort.allCases,
          label: { $0.title },
          selection: $sort,
          showTimeRange: true,
          timeRange: $timeRange
        )
      }
  }
  .frame(width: 900, height: 600)
}
