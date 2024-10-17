//
//  ShapePalette.swift
//  ToggleLayout
//
//  Created by Tom Bunch on 9/29/24.
//

import SwiftUI

struct ShapePalette: View {
    var expanded: Bool = true
    @State private var selected: Bool = false
    var body: some View {
        if expanded {
            fullPalette
        } else {
            mediumPalette
        }
    }
    
    var fullPalette: some View {
        VStack() {
            mediumPalette
            Divider()
            Toggle("Allow connections from lines", isOn: Binding(get: {
                true
            }, set: { _ in
            }))
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    @ViewBuilder var mediumPalette: some View {
        HStack {
            Image(systemName: "square")
                .resizable()
                .frame(width: 80, height: 80)
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selected.toggle()
                }
                .background {
                    RoundedRectangle(cornerRadius: 6).fill(.blue).opacity(selected ? 1 : 0)
                }

        }
    }
}
