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
            "• Select the text in the field below.\n" +
            "• Tap on rows in the panel titled 'AppKit Window'\n" +
            "• The rows react to the taps, and don't steal focus from the main window.\n" +
            "• That is the desired behavior: the list responds to clicks without stealing focus from the main window.\n" +
            "• Tap once on a row in the panel titled 'SwiftUI Panel'\n" +
            "    In Sequoia 15 the row reacts to the taps, and doesn't steal focus from the main window.\n" +
            "    In Sonoma 14 tapping on the list does nothing. If you tap the panel's title bar it becomes key, and then tapping on the list selects rows.\n" +
            "• (The sample text in the field below is just provided to make key state more visible)\n"
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
        let panel = NSPanel(contentRect: NSRect(x: 100, y: 500, width: 400, height: 400), styleMask: [.utilityWindow, .titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)
        panel.isFloatingPanel = true
        panel.title = "SwiftUI Panel (broken)"
        panel.becomesKeyOnlyIfNeeded = true
        
        let windowController = NSWindowController(window: panel)
        let paletteViewController = PanelViewController(window: panel)
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
