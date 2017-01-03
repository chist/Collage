//
//  ScrollView.swift
//  Collage
//
//  Created by Ivan Chistyakov on 05.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa
import Quartz

class ScrollViewCreator {
    func make(_ image: NSImage, border: Rectangle) -> NSScrollView {
        let tmpView = DragAndDropImageView()
        tmpView.image = image
        tmpView.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        
        let scrollView = NSScrollView()
        scrollView.allowsMagnification = true
        scrollView.frame = border.framed().toNSRect()
        scrollView.documentView = tmpView
        scrollView.minMagnification = max(scrollView.frame.size.height / image.size.height, scrollView.frame.size.width / image.size.width)
        scrollView.maxMagnification = 10
        scrollView.magnification = scrollView.minMagnification
        scrollView.drawsBackground = false

        return scrollView
    }
}

