//
//  HelpView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 03.10.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Help: NSView {
    var isActive: Bool = false
    let size = CGSize(width: 230, height: 350)
    let background = NSImage(named: "helpBackground")
    var hint: NSView?
    
    let hintText = "Click with right mouse button to open / close menu.\nIt allows you to add new partitions and change photos.\n\nDrag frame borders to resize collage and partitions!\n\nYou can also drag-and-drop pictures from Finder!\n\nPress help button to show that again.\n\n"
    
    init(superView: NSView) {
        super.init(frame: NSRect())
        
        // create view with appropriate frame and background
        let center = Rectangle.init(fromNSRect: superView.frame).getCenter();
        let origin = NSPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.frame = NSRect(origin: origin, size: self.size)
        self.frame = self.frame
        
        let backgroundFrame = NSRect(origin: CGPoint(x: 0, y: 0), size: self.size);
        let imageView = NSImageView(frame: backgroundFrame)
        imageView.image = self.background
        imageView.imageScaling = NSImageScaling.scaleAxesIndependently
        self.addSubview(imageView)
        
        // add view with text
        hint = Hint(with: hintText, toFit: self.size).getView()
        self.addSubview(hint!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contains(point: NSPoint) -> Bool {
        if Rectangle.init(fromNSRect: self.frame).checkIfContains(point) {
            return true
        }
        return false
    }
    
    func locateView(at point: CGPoint) {
        let correctedPoint = CGPoint(x: point.x - self.frame.width / 2,
                                     y: point.y - self.frame.height / 2)
        self.frame = NSRect(origin: correctedPoint, size: self.frame.size)
        
        // update hint to get smooth text on the screen
        hint?.removeFromSuperview()
        hint = Hint(with: hintText, toFit: self.size).getView()
        self.addSubview(hint!)
    }
}
