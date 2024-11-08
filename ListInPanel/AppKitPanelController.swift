//
//  AppKitPanelController.swift
//  ListInPanel
//
//  Created by Tom Bunch on 11/8/24.
//

import Cocoa

class AppKitPanelController: NSWindowController, NSTableViewDataSource, NSWindowDelegate {
    @IBOutlet var tableView: NSTableView!
    
    override var windowNibName: NSNib.Name? {
        "AppKitPanelController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        if let panel = self.window as? NSPanel {
            panel.becomesKeyOnlyIfNeeded = true
            tableView?.needsDisplay = true
        }
    }
    
    // NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return "Row \(row)"
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
    }
}
