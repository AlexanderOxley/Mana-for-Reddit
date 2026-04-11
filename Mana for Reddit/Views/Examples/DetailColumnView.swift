//
//  DetailColumnView.swift
//  NavigationSplitView
//
/**
import SwiftUI

struct DetailColumnView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.name)
                .font(.title)
                .fontWeight(.bold)
            Text(item.description)
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle(item.name)
    }
}

#Preview {
    NavigationStack {
        DetailColumnView(
            item: Item(name: "Swift", description: "A programming language for Apple platforms")
        )
    }
}
**/
