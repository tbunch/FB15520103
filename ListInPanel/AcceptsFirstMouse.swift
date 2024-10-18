//
//  AcceptsFirstMouse.swift
//  ListInPanel
//
//  Created by Tom Bunch on 10/18/24.
//

import AppKit
import SwiftUI

class AcceptsFirstMouseHostingView<Content>: NSHostingView<Content> where Content : View {
    public override var acceptsFirstResponder: Bool {
        true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
//    override var needsPanelToBecomeKey: Bool {
//        get {
//            return true
//        }
//    }
    
    override var mouseDownCanMoveWindow: Bool {
        get {
            return false
        }
    }
}
