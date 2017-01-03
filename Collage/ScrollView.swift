//
//  ScrollView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 05.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class MutableScrollView: NSScrollView, ScrollViewDelegate {
    let content = DragAndDropImageView()
    let border: Rectangle
    
    init(image: NSImage, border: Rectangle) {
        self.border = border
        super.init(frame: NSRect())
        
        content.image = image
        content.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        content.delegate = self
        
        self.allowsMagnification = true
        self.frame = border.framed().toNSRect()
        self.documentView = content
        self.minMagnification = max(self.frame.size.height / image.size.height, self.frame.size.width / image.size.width)
        self.maxMagnification = 100
        self.magnification = self.minMagnification
        self.drawsBackground = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if let image = content.image {
            content.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: image.size)
            
            self.frame = border.framed().toNSRect()
            self.documentView = content
            self.minMagnification = max(self.frame.size.height / image.size.height, self.frame.size.width / image.size.width)
            self.magnification = self.minMagnification
        }
    }
}
