//
//  FocusView.swift
//  OmniGraffle
//
//  Created by Ryan Patrick on 3/13/21.
//

import SwiftUI
import UniformTypeIdentifiers

public class PaletteFocusState: ObservableObject {
    @Published public var isFocused = false
    @Published public var isEditing = false

    public init(isFocused: Bool = false, isEditing: Bool = false) {
        self.isFocused = isFocused
        self.isEditing = isEditing
    }

    public var selectionColor: SwiftUI.Color {
        if isEditing {
            return Color.clear  // if editing, hightlights provided by NSTextField
        }
        #if OMNI_BUILDING_FOR_MAC
        return isFocused ? Color(OAPlatformColorClass.selectedContentBackgroundColor) : Color(nsColor: NSColor.unemphasizedSelectedContentBackgroundColor)
        #else
        return Color.accentColor
        #endif
    }
    
    public static func textColor(focused: Bool, selected: Bool) -> SwiftUI.Color {
        if focused == false && selected == true {
            return Color(NSColor.selectedControlTextColor)
        }
        if selected {
            return Color(NSColor.alternateSelectedControlTextColor)
        }
        return Color(NSColor.controlTextColor)
    }
    
    public static func controlColor(focused: Bool, selected: Bool) -> SwiftUI.Color {
        if focused == true && selected == true {
            return Color(NSColor.alternateSelectedControlTextColor)
        }
        return Color(NSColor.secondaryLabelColor)
    }
    
    public static func outlineColor(focused: Bool) -> SwiftUI.Color {
        if focused == true {
            return Color(NSColor.selectedTextBackgroundColor)
        }
        return Color(NSColor.unemphasizedSelectedTextBackgroundColor)
    }
}

extension View {
    public func paletteFocusView(paletteFocusState: PaletteFocusState = PaletteFocusState(), onCommand: @escaping (PaletteNSViewAction) -> Void = { _ in }, validate: ((PaletteNSViewAction) -> Bool)? = nil, perform: ((PaletteNSViewAction, AnyObject?) -> Void)? = nil) -> some View {
        PaletteFocusView(paletteFocusState: paletteFocusState, onCommand: onCommand, validate: validate, performAction: perform) { self }
    }
}

struct PaletteFocusView<Content: View>: View {
    @StateObject var paletteFocusState: PaletteFocusState
    let onCommand: (PaletteNSViewAction) -> Void
    let validate: ((PaletteNSViewAction) -> Bool)?
    let performAction: ((PaletteNSViewAction, AnyObject?) -> Void)?
    
    let content: () -> Content

    @FocusState var containerFocus: Bool

    var body: some View {
        content()
            .background(FocusView(onCommand: onCommand, validate: validate, perform: performAction))
            .focused($containerFocus)
            .environmentObject(paletteFocusState)
            .onChange(of: paletteFocusState.isFocused) {
                containerFocus = $0
                print("change of isFocused - containerFocus: \(containerFocus)")
            }
            .onChange(of: containerFocus) {
                paletteFocusState.isFocused = $0
                print("change of containerFocus: \(containerFocus)")
            }
    }
}

@objc public enum PaletteNSViewAction: Int {
    case indent
    case outdent
    case newLine
    case delete
    case moveUp
    case moveDown
    case moveRight
    case moveLeft
    case cut
    case copy
    case paste
}

extension Bool {
    var focusedStateColor: SwiftUI.Color {
        if self {
            return Color.accentColor
        }
        return Color.secondary
    }
}

public struct TextView: View {
    @Binding var text: String
    @Binding var focus: Bool
    @Binding var editing: Bool
    @Binding var selected: Bool
    var placeholder = "<empty>"
    
    let alternateAction: () -> Void
    let shiftAction: () -> Void
    
    let onCommand: (PaletteNSViewAction) -> Void
    let validate: ((PaletteNSViewAction) -> Bool)?
    @SwiftUI.Environment(\.controlActiveState) var windowState: ControlActiveState

    public init(text: Binding<String>, focus: Binding<Bool>, editing: Binding<Bool>, selected: Binding<Bool>, placeholder: String = "<empty>", alternateAction: @escaping () -> Void, shiftAction: @escaping () -> Void, onCommand: @escaping (PaletteNSViewAction) -> Void = { _ in }, validate: ( (PaletteNSViewAction) -> Bool)? = nil) {
        _text = text
        _focus = focus
        _editing = editing
        _selected = selected
        self.placeholder = placeholder
        self.alternateAction = alternateAction
        self.shiftAction = shiftAction
        self.onCommand = onCommand
        self.validate = validate
    }
    
    public var body: some View {
        if selected == true, editing == true {
            RowEditor(text: $text, editing: $editing, onCommand: onCommand, validate: validate)
                .onChange(of: windowState) { newWindowState in
                    if newWindowState != .key, editing == true {
                        editing = false
                        focus = false
                    }
                }
                .onTapGesture { /* intentionally left blank; consume the tap so that it doesnt get to the view below the editor */ }
        } else {
            Text(text.isEmpty ? placeholder : text)
                .gesture(TapGesture().modifiers(.command).onEnded {
                    editing = false
                    alternateAction()
                })
                .gesture(TapGesture().modifiers(.shift).onEnded {
                    editing = false
                    shiftAction()
                })
                .onTapGesture {
                    if selected, focus == false {
                        focus = true
                        return
                    }
                    if selected, focus, editing == false {
                        editing = true
                        return
                    }
                    editing = false
                    selected = true
                }
                .foregroundColor(textColor)
                .onChange(of: windowState) { newWindowState in
                    if newWindowState != .key, focus == true {
                        editing = false
                        focus = false
                    }
                }
                .lineLimit(1)
        }
    }
    
    var textColor: SwiftUI.Color {
        if text.isEmpty {
            return Color.secondary
        }
        return PaletteFocusState.textColor(focused: focus, selected: selected)
    }
}

struct RowEditor: View {
    @Binding var text: String
    @Binding var editing: Bool
    @SwiftUI.FocusState private var focusedField: Bool
    @SwiftUI.Environment(\.controlActiveState) var windowState: ControlActiveState
    
    let onCommand: (PaletteNSViewAction) -> Void
    let validate: ((PaletteNSViewAction) -> Bool)?
    
    var body: some View {
        PaletteTextView(text: textBinding, onCommand: doCommand)
            .onChange(of: windowState) { newWindowState in
                if newWindowState != .key, editing == true {
                    editing = false
                    focusedField = false
                }
            }
            .onTapGesture { /* intentionally left blank; consume the tap so that it doesnt get to the view below the editor */ }
            .focused($focusedField)
            .onAppear {
                focusedField = true
            }
            .onChange(of: focusedField) { newFocus in
                if !newFocus {
                    editing = false
                }
            }
            .onDisappear {
                editing = false
            }
    }
    
    private var textBinding: Binding<String> {
        Binding {
            text
        } set: { newValue in
            text = newValue
            editing = false
        }
    }
    func doCommand(_ action: PaletteNSViewAction, _ textView: NSTextView) -> Bool {
        guard let validate = validate, validate(action) else { return false }
        onCommand(action)
        return true
    }
}

public struct PaletteTextView: NSViewRepresentable {
    public typealias NSViewType = PaletteNSTextField
    
    public class Coordinator: NSObject, NSTextFieldDelegate {

        @Binding var text: String
        private var edited = false

        public init(text: Binding<String>) {
            _text = text
        }

        public func controlTextDidBeginEditing(_ obj: Notification) {
            guard let _ = obj.object as? PaletteNSTextField else { return }
            edited = true
        }

        public func controlTextDidEndEditing(_ obj: Notification) {
            guard edited else { return }
            guard let textField = obj.object as? PaletteNSTextField else { return }
            text = textField.stringValue
            edited = false
        }

        public func controlTextDidChange(_ obj: Notification) {
            guard let _ = obj.object as? PaletteNSTextField else { return }
            edited = true
        }
    }
    
    @Binding var text: String
    var onCommand: (PaletteNSViewAction, NSTextView) -> Bool
    var alignment: NSTextAlignment
    var placeholder: String = ""
    var resetButton: Bool = false
    
    private var coordinator: Coordinator
    @SwiftUI.Environment(\.isEnabled) private var isEnabled

    public init(text textBinding: Binding<String>, onCommand: @escaping (PaletteNSViewAction, NSTextView) -> Bool = { _, _ in false }, alignment: NSTextAlignment = .left, placeholder: String = "", resetButton: Bool = false) {
        _text = textBinding
        self.onCommand = onCommand
        self.alignment = alignment
        self.placeholder = placeholder
        coordinator = Coordinator(text: textBinding)
        self.resetButton = resetButton
    }

    public func makeNSView(context: NSViewRepresentableContext<PaletteTextView>) -> PaletteNSTextField {
        let textField = PaletteNSTextField(frame: .zero)
        update(paletteTextField: textField, context: context)
        textField.cell?.isScrollable = true
        textField.resetButton = resetButton
        return textField
    }

    public func makeCoordinator() -> PaletteTextView.Coordinator {
        return coordinator
    }

    public func updateNSView(_ nsView: PaletteNSTextField, context: NSViewRepresentableContext<PaletteTextView>) {
        nsView.stringValue = text
        update(paletteTextField: nsView, context: context)
        if nsView.resetButton != resetButton {
            nsView.resetButton = resetButton
        }
    }
    
    private func update(paletteTextField: PaletteNSTextField, context: NSViewRepresentableContext<PaletteTextView>) {
        paletteTextField.controlSize = .regular
        paletteTextField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        paletteTextField.alignment = alignment
        paletteTextField.delegate = context.coordinator
        paletteTextField.onCommand = onCommand
        paletteTextField.placeholderString = placeholder
    }
}

class FocusTextViewCell: NSTextFieldCell {
    var fieldEditor: PaletteNSTextView? = nil
    override func fieldEditor(for controlView: NSView) -> NSTextView? {
        if fieldEditor == nil {
            fieldEditor = PaletteNSTextView(frame: controlView.bounds)
            fieldEditor?.isFieldEditor = true
            fieldEditor?.usesFontPanel = false
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineBreakMode = .byClipping
            let attributes = [NSAttributedString.Key.paragraphStyle: pStyle]
            fieldEditor?.typingAttributes = attributes
            if let field = controlView as? PaletteNSTextField {
                fieldEditor?.onCommand = field.onCommand
            }
        }
        return fieldEditor
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        guard let focusTextField = controlView as? PaletteNSTextField, focusTextField.resetButton else {
            super.select(withFrame: rect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
            return
        }
        let (labelFrame, _) = PaletteNSTextField.drawingRects(frame: controlView.frame)
        super.select(withFrame: labelFrame, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}

class PaletteNSTextView: NSTextView {
    var onCommand: (PaletteNSViewAction, NSTextView) -> Bool = { _,_ in false }

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func doCommand(by selector: Selector) -> Void {
        var action: PaletteNSViewAction? = nil
        switch selector {
        case #selector(NSResponder.indent(_:)): action = .indent
        case #selector(NSResponder.insertTab(_:)): action = .indent
        case #selector(NSResponder.insertBacktab(_:)): action = .outdent
        case #selector(NSResponder.insertNewline(_:)): action = .newLine
        case #selector(NSResponder.deleteBackward(_:)): action = .delete
        case #selector(NSResponder.moveUp(_:)): action = .moveUp
        case #selector(NSResponder.moveDown(_:)): action = .moveDown
        case #selector(NSResponder.moveRight(_:)): action = .moveLeft
        case #selector(NSResponder.moveLeft(_:)): action = .moveRight
        default: break
        }

        if let action = action, onCommand(action, self) {
            return
        } else if let action = action, let textFieldDelegate = delegate as? PaletteNSTextField, textFieldDelegate.onCommand(action, self) {
            return
        }
        
        // special case cancel operation to call .abortEdit on the containing text field
        if selector == #selector(NSResponder.cancelOperation(_:)), let textFieldDelegate = delegate as? PaletteNSTextField {
            let _ = textFieldDelegate.abortEditing()
            return
        }
        
        super.doCommand(by: selector)
    }

    override var acceptsFirstResponder: Bool { return true }
}

public class PaletteNSTextField: NSTextField {
    var onCommand: (PaletteNSViewAction, NSTextView) -> Bool = { _,_ in false }
    var hasChanged: Bool = false
    var resetButton: Bool = false

    static public override var cellClass: AnyClass? {
        get {
            FocusTextViewCell.self
        }
        set {
            super.cellClass = newValue
        }
    }

    public override func resetCursorRects() {
        guard resetButton else {
            super.resetCursorRects()
            return
        }
        
        let (textRect, buttonRect) = PaletteNSTextField.drawingRects(frame: self.frame)
        addCursorRect(textRect, cursor: NSCursor.iBeam)
        addCursorRect(buttonRect, cursor: NSCursor.arrow)
    }
    
    static let resetButtonWidth: CGFloat = 10
    public static func drawingRects(frame: NSRect) -> (NSRect, NSRect) {
        var buttonRect = NSRect()
        var textRect = NSRect()
        NSDivideRect(frame, &buttonRect, &textRect, PaletteNSTextField.resetButtonWidth, NSRectEdge.maxX)
        
        return (textRect, buttonRect)
    }
    
}

extension NSView {
    var isFirstResponder: Bool {
        return window?.firstResponder == self
    }
    
    func grabFirstResponder() {
        DispatchQueue.main.async {
            self.window?.makeFirstResponder(self)
        }
    }
}

@objc public class FocusNSView: NSView {
    let onCommand: (PaletteNSViewAction) -> Void
    let validateAction: ((PaletteNSViewAction) -> Bool)?
    let performAction: ((PaletteNSViewAction, AnyObject?) -> Void)?
    
    init(onCommand: @escaping (PaletteNSViewAction) -> Void, validate: ((PaletteNSViewAction) -> Bool)?, perform: ((PaletteNSViewAction, AnyObject?) -> Void)?) {
        self.onCommand = onCommand
        self.validateAction = validate
        self.performAction = perform
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var acceptsFirstResponder: Bool { return true }
    public override var canBecomeKeyView: Bool { return true }
    
    @objc public func validate(_ action: PaletteNSViewAction) -> Bool {
        if let validateAction = validateAction {
            return validateAction(action)
        }
        
        return false
    }
    
    @objc public func perform(_ action: PaletteNSViewAction, sender: AnyObject?) {
        if let performAction = performAction {
            performAction(action, sender)
        } else {
            onCommand(action)
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    // responder events
    public override func indent(_ sender: Any?) {
        onCommand(.indent)
    }
    
    public override func insertTab(_ sender: Any?) {
        onCommand(.indent)
    }
    
    public override func insertBacktab(_ sender: Any?) {
        onCommand(.outdent)
    }
    
    public override func insertNewline(_ sender: Any?) {
        onCommand(.newLine)
    }
    
    public override func deleteBackward(_ sender: Any?) {
        onCommand(.delete)
    }
    
    public override func moveUp(_ sender: Any?) {
        onCommand(.moveUp)
    }
    
    public override func moveDown(_ sender: Any?) {
        onCommand(.moveDown)
    }
    
    public override func moveRight(_ sender: Any?) {
        onCommand(.moveRight)
    }
    
    public override func moveLeft(_ sender: Any?) {
        onCommand(.moveLeft)
    }
}

struct FocusView: NSViewRepresentable {
    let onCommand: (PaletteNSViewAction) -> Void
    let validate: ((PaletteNSViewAction) -> Bool)?
    let performAction: ((PaletteNSViewAction, AnyObject?) -> Void)?

    init(onCommand: @escaping (PaletteNSViewAction) -> Void = { _ in }, validate: ((PaletteNSViewAction) -> Bool)? = nil, perform: ((PaletteNSViewAction, AnyObject?) -> Void)? = nil) {
        self.onCommand = onCommand
        self.validate = validate
        self.performAction = perform
    }
        
    func makeNSView(context: Context) -> FocusNSView {
        return FocusNSView(onCommand: onCommand, validate: validate, perform: performAction)
    }
    
    func updateNSView(_ nsView: FocusNSView, context: Context) { }
    
    typealias NSViewType = FocusNSView
    typealias Context = NSViewRepresentableContext<Self>    // this is necessary since there is a conflict with OmniJS.Context
}

