//
//  ScrollablePalette.swift
//  ToggleLayout
//
//  Created by Tom Bunch on 9/30/24.
//

import SwiftUI

struct ScrollablePalette: View {
    var window: NSWindow
    
    @State private var selected: Set<Int> = Set()
    private var selectionColor: Color {
        get {
            window.isKeyWindow ? Color(NSColor.selectedContentBackgroundColor) : Color(NSColor.unemphasizedSelectedContentBackgroundColor)
        }
    }
    
    var body: some View {
        List(1..<20) { index in
            Text("Row \(index)")
                .frame(maxWidth: .infinity)
                .padding(4)
                .contentShape(Rectangle())
                .onKeyPress { press in
                    print("\(press.characters)")
                    return .handled
                }
                .trivialWrapper()
                .background {
                    RoundedRectangle(cornerRadius: 6).fill(selectionColor).opacity(selected.contains(index) ? 1 : 0)
                }
                .onTapGesture {
                    if selected.contains(index) {
                        window.becomeKey()
                    } else {
                        selected.insert(index)
                    }
                }
                .listRowSeparator(.hidden)
        }
        .frame(minWidth: 400, minHeight: 600)
        .padding()
    }
}

