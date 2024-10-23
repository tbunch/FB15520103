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
    @FocusState private var focused: Bool
    @State private var selectionColor = Color.blue
    
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
                    RoundedRectangle(cornerRadius: 6).fill(selectionColor).opacity(selected.contains(index) ? 1 : 0)
                    // uncommenting the following two lines causes the doesn't-get-taps bug. We need to be able to do this if we are to change the selection color based on whether the view is focused.
                    // .focusable()
                    // .focused($focused)
                        .onKeyPress { press in
                            print("\(press.characters)")
                            return .handled
                        }
                }
                .onTapGesture {
                    if let indexInSelected = selected.firstIndex(of: index) {
                        selected.remove(at: indexInSelected)
//                        focused = true
                    } else {
                        selected.append(index)
                    }
                }
        }
        .frame(height: 150)
        .onChange(of: focused) { oldValue, newValue in
//            selectionColor = newValue ? .blue : .gray
        }
        // uncommenting the following line causes the doesn't-get-taps bug. In OmniGraffle we have a more complicated wrapper to help determine if the view is focused or if a text field is editing within it. It turns out even a trivial wrapper provokes the bug
//        .trivialWrapper()
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
