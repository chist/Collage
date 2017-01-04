//
//  DragAndDropImageView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 04.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class DragAndDropImageView: NSImageView {
    var updateDelegate: ScrollViewDelegate?
    var mouseClickDelegate: MouseClickDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isEditable = true
        
        mouseClickDelegate = NSApplication.shared().windows[0].contentViewController as! MouseClickDelegate?
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isEditable = true
        
        mouseClickDelegate = NSApplication.shared().windows[0].contentViewController as! MouseClickDelegate?
    }
    
    override var image: NSImage? {
        didSet {
            super.image = image
            updateDelegate?.update()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        // don't accept left mouse clicks, let initial ViewController process them
        mouseClickDelegate?.mouseDown(with: event)
    }
}
