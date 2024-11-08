import SwiftUI

private var detachedWindowControllers: [NSWindowController] = []

class PanelViewController: NSViewController {
    var hostingView: NSHostingView<ScrollablePalette>

    init() {
        let paletteView = ScrollablePalette()
        hostingView = NSHostingView(rootView: paletteView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.sizingOptions = [.minSize, .standardBounds]
        hostingView.isFlipped = false
        
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
}

