//
//  ContentView.swift
//  ListInPanel
//
//  Created by Tom Bunch on 10/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var someText = "sample text"
    
    var body: some View {
        GeometryReader { containerGeometry in
            HStack {
                VStack(alignment: .leading) {
                    Text("• Open the popover with List")
                    Text("• Test that tap select/deselcts rows")
                    Text("• Detach the popover")
                    Text("• Test that tap works")
                    Text("• Click on the main window")
                    Text("• Test that tap no longer works")
                    Text("• Note that the chevron still works")
                    Text("• Note that selection in the other")
                    Text("  popover doesn't exhibit this bug")
                    TextField(text: $someText) {
                        Text("gratuitous field:")
                    }
                }

                VStack {
                    Button(action: {
                        if let currentEvent = NSApplication.shared.currentEvent, let window = currentEvent.window {
                            _ = openPalettePopover(in: window, geometry: containerGeometry, containingList: true)
                        }
                    }, label: {
                        Text("Open Popover with List")
                    })
                    Button(action: {
                        if let currentEvent = NSApplication.shared.currentEvent, let window = currentEvent.window {
                            _ = openPalettePopover(in: window, geometry: containerGeometry, containingList: false)
                        }
                    }, label: {
                        Text("Open popover without")
                    })
                }
            }
            .frame(width: 400, height: 200)
        }
        .padding()
    }
               
    private func openPalettePopover(in parent: NSWindow, geometry: GeometryProxy, containingList: Bool) -> Bool {
        var buttonFrameInWindowSpace = geometry.frame(in: .global)
        buttonFrameInWindowSpace.origin.y = parent.frame.size.height - buttonFrameInWindowSpace.maxY    // .frame(in:) is flipped y-axis on macOS 12
        
        guard let hitView = parent.contentView else {
            print("Issue opening palette popover: hit view not found")
            return false
        }
        PaletteColumnViewPopover.popover(view: hitView, rect: buttonFrameInWindowSpace, containingList: containingList)
        return true
    }
}

#Preview {
    ContentView()
}
