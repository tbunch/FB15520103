//
//  ScrollablePalette.swift
//  ToggleLayout
//
//  Created by Tom Bunch on 9/30/24.
//

import SwiftUI

struct ScrollablePalette: View {
    var expanded: Bool = true
    @State private var selected: [Int] = []
    
    var body: some View {
        if expanded {
            fullPalette
        } else {
            Text("Fixed height, ignore size pref")
        }
    }
    
    var fullPalette: some View {
        List(1..<20) { index in
            Text("Row \(index)")
                .frame(maxWidth: .infinity)
                .padding(4)
                .contentShape(Rectangle())
                .background {
                    RoundedRectangle(cornerRadius: 6).fill(.blue).opacity(selected.contains(index) ? 1 : 0)
                }
                .onTapGesture {
                    if let indexInSelected = selected.firstIndex(of: index) {
                        selected.remove(at: indexInSelected)
                    } else {
                        selected.append(index)
                    }
                }
        }
        .trivialWrapper()
        .frame(height: 150)
    }
}

extension ShapeStyle where Self == Color {
    static public var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
