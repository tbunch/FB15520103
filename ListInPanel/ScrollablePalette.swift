//
//  ScrollablePalette.swift
//  ToggleLayout
//
//  Created by Tom Bunch on 9/30/24.
//

import SwiftUI

struct ScrollablePalette: View {
    @State private var selected: [Int] = []
//    @FocusState private var focused: Int?
    @State private var selectionColor = Color.blue
    
    var body: some View {
        List(1..<20) { index in
            Text("Row \(index)")
                .frame(maxWidth: .infinity)
                .padding(4)
                .contentShape(Rectangle())
//                .focusable()
//                .focused($focused, equals: index)
                .onKeyPress { press in
                    print("\(press.characters)")
                    return .handled
                }
                .background {
                    RoundedRectangle(cornerRadius: 6).fill(selectionColor).opacity(selected.contains(index) ? 1 : 0)
                }
                .onTapGesture {
                    if let indexInSelected = selected.firstIndex(of: index) {
                        selected.remove(at: indexInSelected)
//                        focused = index
                    } else {
                        selected.append(index)
                    }
                }
        }
        .frame(minWidth: 400, minHeight: 600)
        .padding()
//        .onChange(of: focused) { oldValue, newValue in
//        }
    }
}

