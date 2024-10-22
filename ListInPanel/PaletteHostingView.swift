//
//  PaletteHostingView.swift
//
//  Created by Tom Bunch on 10/18/24.
//

import AppKit
import SwiftUI

class PaletteHostingView<Content>: NSHostingView<Content> where Content : View {
    public override var acceptsFirstResponder: Bool {
        true
    }
       
    override var needsPanelToBecomeKey: Bool {
        get {
            return true
        }
    }
}
