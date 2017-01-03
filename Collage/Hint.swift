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
    let xIndent: CGFloat = 20
    let yIndent: CGFloat = 60
    
    init(with text: String, toFit size: NSSize) {
        self.view.frame = NSRect(origin: NSPoint(), size: size)
        self.textView.frame = NSRect(x: xIndent, y: yIndent, width: size.width - 2 * xIndent, height: size.height - 2 * yIndent)
        self.textView.string = text
        self.textView.isEditable = false
        self.textView.textColor = NSColor(calibratedWhite: 1, alpha: 1)
        self.textView.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0)
        self.textView.isSelectable = false;
        self.textView.font = NSFont.systemFont(ofSize: 14)
        self.textView.alignment = NSTextAlignment.center
        self.textView.sizeToFit()
        //self.textView.textStorage?.applyFontTraits(NSFontTraitMask.posterFontMask, range: NSMakeRange(0, text.characters.count))
        self.view.addSubview(textView)
    }
    
    func getView() -> NSView {
        return self.view
    }
}
