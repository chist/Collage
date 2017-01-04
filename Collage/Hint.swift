//
//  HintView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 04.11.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Hint {
    let view = NSView()
    let textView = NSTextView()
    
    init(with text: String, toFit size: NSSize) {
        self.view.frame     = NSRect(origin: NSPoint(), size: size)
        self.textView.frame = NSRect(origin: NSPoint(), size: size)
        self.textView.string = text
        self.textView.isEditable = false
        self.textView.textColor = NSColor(calibratedWhite: 1, alpha: 1)
        self.textView.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0)
        self.textView.isSelectable = false;
        self.textView.font = NSFont.init(name: "Comic Sans MS", size: 15)
        self.textView.alignment = NSTextAlignment.center
        self.textView.sizeToFit()
        self.view.addSubview(textView)
    }
    
    func getView() -> NSView {
        return self.view
    }
}
