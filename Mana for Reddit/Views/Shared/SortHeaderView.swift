//
//  SortHeaderView.swift
//  Mana for Reddit
//
//  Created by Alexander Oxley on 14.04.2026.
//

import SwiftUI

struct SortHeaderView<Option: Hashable>: View {
  let title: String
  let options: [Option]
  let label: (Option) -> String
  @Binding var selection: Option
  let showTimeRange: Bool
  @Binding var timeRange: TimeRange

  var body: some View {
    HStack(spacing: 12) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)

      Spacer(minLength: 8)

      Picker("Sort", selection: $selection) {
        ForEach(options, id: \.self) { option in
          Text(label(option)).tag(option)
        }
      }
      .pickerStyle(.menu)

      if showTimeRange {
        Picker("Time", selection: $timeRange) {
          ForEach(TimeRange.allCases, id: \.self) { range in
            Text(range.title).tag(range)
          }
        }
        .pickerStyle(.menu)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(.ultraThinMaterial)
  }
}

#Preview {
  @Previewable @State var sort = PostSort.best
  @Previewable @State var timeRange = TimeRange.today

  SortHeaderView(
    title: "Posts",
    options: PostSort.allCases,
    label: { $0.title },
    selection: $sort,
    showTimeRange: true,
    timeRange: $timeRange
  )
}
