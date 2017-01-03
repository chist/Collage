//
//  HelpView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 03.10.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Help {
    var isActive: Bool = false
    var frame = NSRect()
    let size = CGSize(width: 230, height: 300)
    let background = NSImage(named: "helpBackground")
    let view = NSView()
    let superView: NSView
    var hint: Hint
    
    let hintText = "Click right mouse button to see menu.\n\nDrag frame border to change proportions. You can also change it by resizing the app window.\n\nBy default your collages are saved in Documents folder but you can change it in app preferences."
    
    init(superView: NSView) {
        self.superView = superView
        
        // create view with appropriate frame and background
        let center = Rectangle.init(fromNSRect: superView.frame).getCenter();
        let origin = NSPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.frame = NSRect(origin: origin, size: self.size)
        self.view.frame = self.frame
        
        let backgroundFrame = NSRect(origin: CGPoint(x: 0, y: 0), size: self.size);
        let imageView = NSImageView(frame: backgroundFrame)
        imageView.image = self.background
        imageView.imageScaling = NSImageScaling.scaleAxesIndependently
        self.view.addSubview(imageView)
        
        // add view with text
        hint = Hint(with: hintText, toFit: self.size)
        self.view.addSubview(hint.view)
    }
    
    func contains(point: NSPoint) -> Bool {
        if Rectangle.init(fromNSRect: view.frame).checkIfContains(point) {
            return true
        }
        return false
    }
    
    func show() {
        if self.isActive {
            return
        }
        
        // calculate appropriate help view position
        self.view.frame = NSRect(origin: CGPoint(x: superView.frame.midX - view.frame.width / 2, y: superView.frame.midY - view.frame.height / 2), size: size)
        self.superView.addSubview(self.view)
        
        // create new hint view to avoid font bugs
        hint.view.removeFromSuperview()
        hint = Hint(with: hintText, toFit: size)
        self.view.addSubview(hint.view)
        
        // change state
        self.isActive = true
    }
    
    func hide() {
        self.view.removeFromSuperview()
        self.isActive = false
    }
    
    func changeState() {
        if self.isActive {
            self.hide()
        } else {
            self.show()
        }
    }
}
