//
//  ContentView.swift
//  ListInPanel
//
//  Created by Tom Bunch on 10/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var someText = "sample text"
    let controller = AppKitPanelController()
    
    var body: some View {
        VStack(alignment: .leading) {
            let instructions =
            "• Find the panel in the left of the screen\n" +
            "• Tap some a row - panel becomes key, row not selected\n" +
            "• Tap some rows - now you can select them\n" +
            "• Tap on the main window\n" +
            "• Tap on more rows - nothing\n" +
            "• But that's because it stole key status, which we don't want\n" +
            "• Repeat tapping main window, rows in panel, titlebar of panel\n" +
            "• (The sample text is just provided to make key state more visible)"
            Text(instructions)
            TextField(text: $someText) {
                Text("gratuitous field:")
            }
        }
        .padding()
        .onAppear {
            showSwiftUIPanel()
            showAppKitPanel()
        }
        .padding()
    }
    
    func showSwiftUIPanel() {
        let panel = NSPanel(contentRect: NSRect(x: 100, y: 500, width: 400, height: 400), styleMask: [.utilityWindow, .nonactivatingPanel, .titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)
        panel.isFloatingPanel = true
        panel.title = "SwiftUI Panel (broken)"
        panel.becomesKeyOnlyIfNeeded = true
        
        let windowController = NSWindowController(window: panel)
        let paletteViewController = PanelViewController()
        windowController.contentViewController = paletteViewController
        
        panel.orderFront(nil)
    }
    
    func showAppKitPanel() {
        controller.window?.orderFront(nil)
    }
    
}

#Preview {
    ContentView()
}
