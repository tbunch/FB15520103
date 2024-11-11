//
//  ScrollablePalette.swift
//  ToggleLayout
//
//  Created by Tom Bunch on 9/30/24.
//

import SwiftUI

struct ScrollablePalette: View {
    @StateObject var focusState = PaletteFocusState()
    @Environment(\.appearsActive) private var appearsActive
    
    @State private var selected: Set<Int> = Set()
    private var selectionColor: Color {
        get {
            appearsActive ? Color(NSColor.selectedContentBackgroundColor) : Color(NSColor.unemphasizedSelectedContentBackgroundColor)
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
                        focusState.isFocused = true
                    } else {
                        selected.insert(index)
                    }
                }
                .listRowSeparator(.hidden)
        }
        .frame(minWidth: 400, minHeight: 600)
        .padding()
        .paletteFocusView(paletteFocusState: focusState, onCommand: doCommand, validate: nil)
    }
    
    func doCommand(_ action: PaletteNSViewAction) {
        switch action {
        case .moveUp:
            selected = Set([(selected.first ?? 1) - 1])
            break
        case .moveDown:
//            selected = Set([(selected.last ?? 1) - 1])
            break
        default:
            break
        }
    }
}

