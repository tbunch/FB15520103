//
//  TrivialWrapper.swift
//  ListInPanel
//
//  Created by Tom Bunch on 10/22/24.
//

import SwiftUI

extension View {
    public func trivialWrapper() -> some View {
        TrivialWrapper() { self }
    }
}

struct TrivialWrapper<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .background(TrivialWrapperRepresentable())
    }
}

struct TrivialWrapperRepresentable : NSViewRepresentable {
    func makeNSView(context: Context) -> TrivialWrapperNSView {
        return TrivialWrapperNSView()
    }
    
    func updateNSView(_ nsView: TrivialWrapperNSView, context: Context) {
    }
    
    typealias NSViewType = TrivialWrapperNSView
    typealias Context = NSViewRepresentableContext<Self>    // this is necessary since there is a conflict with OmniJS.Context
}

@objc public class TrivialWrapperNSView: NSView {
    public override var acceptsFirstResponder: Bool { return true }
    public override var needsPanelToBecomeKey: Bool { return true }
}
