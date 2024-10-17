//
//  PaletteColumnView.swift
//  OmniGraffle
//
//  Created by Ryan Patrick on 6/10/21.
//

import SwiftUI

private var detachedWindowControllers: [NSWindowController] = []

public struct PaletteColumnViewPopover {
    public static func popover(view: NSView, rect: CGRect, edge: NSRectEdge = .minX, containingList: Bool) {
        let paletteView = PalettePopoverContentView(detached: false, containingList: containingList)
        let paletteViewController = PalettePopoverViewController(hosting: paletteView, containingList: containingList)
        
        let popover = NSPopover()
        popover.contentViewController = paletteViewController
        popover.delegate = paletteViewController
        popover.show(relativeTo: rect, of: view, preferredEdge: edge)
    }
}

class PalettePopoverViewController<Content>: NSViewController, NSPopoverDelegate where Content : View {
    var containingList: Bool
    
    init(hosting content: Content, containingList: Bool) {
        self.containingList = containingList
        hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.sizingOptions = [.minSize, .standardBounds]
        
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: hostingView.topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor),
                                     contentView.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor)])
        
        super.init(nibName: nil, bundle: nil)
        
        self.view = contentView
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var hostingView: NSHostingView<Content>
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        guard let popoverViewController = popover.contentViewController as? PalettePopoverViewController, let popoverContentView = popoverViewController.hostingView as? NSHostingView<PalettePopoverContentView> else { return nil }
        guard let popoverWindow = popoverContentView.window else { return nil }
        
        let panel = NSPanel(contentRect: popoverWindow.frame, styleMask: PalettePopoverViewController.popoverStyleMask, backing: .buffered, defer: false)
        panel.becomesKeyOnlyIfNeeded = true
        panel.isFloatingPanel = true
        let windowController = NSWindowController(window: panel)
        let paletteView = PalettePopoverContentView(detached: true, containingList: containingList)
        let paletteViewController = PalettePopoverViewController(hosting: paletteView as! Content, containingList: containingList)
        windowController.contentViewController = paletteViewController
        
        // just leak this forever to prove bug isn't because windowController is disappearing
        detachedWindowControllers.append(windowController)
        return panel
    }
    
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return true
    }
    
    static var popoverStyleMask: NSWindow.StyleMask {
        [.titled, .closable, .resizable, .utilityWindow]
    }
}

public struct PalettePopoverContentView: View {
    var detached: Bool = false
    @State private var expanded: Bool = true
    var containingList: Bool
    public var body: some View {
        VStack {
            if containingList {
                ScrollablePalette(expanded: expanded)
                    .frame(minWidth: 300)
            } else {
                ShapePalette(expanded: expanded)
            }
            Button {
                expanded.toggle()
            } label: {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .renderingMode(.template)
                    .font(.system(size: 12))
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .fixedSize(horizontal: !detached, vertical: true)
    }
}
