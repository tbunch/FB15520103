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
                    Text("• Find the panel in the lower left of the screen")
                    Text("• Tap some rows - nothing happens")
                    Text("• Tap the titlebar of the panel")
                    Text("• Tap some rows - now you can select them")
                    Text("• The last row you tap will be focused")
                    Text("• Tap on the main window")
                    Text("• Tap on rows other than the focused row - nothing")
                    Text("• Tap on the focused row - it works, and you can now tap others")
                    Text("• But that's because it stole key status, which we don't want")
                    Text("• Repeat tapping main window, rows in panel, titlebar of panel")
                    Text("• (The sample text is just provided to make key state more visible)")
                    TextField(text: $someText) {
                        Text("gratuitous field:")
                    }
                }
            }
            .padding()
        }
        .onAppear {
            let panel = NSPanel(contentRect: NSRect(x: 10, y: 10, width: 400, height: 400), styleMask: [.titled, .closable, .resizable, .utilityWindow], backing: .buffered, defer: false)
            panel.becomesKeyOnlyIfNeeded = true
            panel.isFloatingPanel = true
            let windowController = NSWindowController(window: panel)
            let paletteViewController = PanelViewController()
            windowController.contentViewController = paletteViewController
            panel.orderFront(nil)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
