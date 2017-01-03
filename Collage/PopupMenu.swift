//
//  PopupMenu.swift
//  Collage
//
//  Created by Ivan Chistyakov on 05.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class PopUpMenuView: NSView {
    var isActive = false // true if menu is visible
    let buttonNames = ["splitVertically", "splitHorizontally", "merge", "choosePhoto"]
    let optionHeight: Int = 48
    let optionWidth: Int = 160
    var delegate: MenuDelegate?
    
    init(canvasController: CanvasController) {
        super.init(frame: NSRect())
        self.becomeFirstResponder()
        delegate = canvasController
        
        self.frame = NSRect(x: 0, y: 0, width: optionWidth, height: optionHeight * buttonNames.count)
        for i in 0...(buttonNames.count - 1) {
            let buttonView = NSImageView()
            buttonView.image = NSImage(named: buttonNames[i])
            buttonView.frame = NSRect(x: 0, y: i * optionHeight, width: optionWidth, height: optionHeight)
            buttonView.isEditable = false
            self.addSubview(buttonView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let mode: Int = Int(point.y) / optionHeight
        delegate?.menuItemIsChosen(mode: mode)
        self.removeFromSuperview()
        self.isActive = false
    }
    
    func locateView(at point: CGPoint) {
        let correctedPoint = CGPoint(x: Int(point.x) - optionWidth / 2,
                                     y: Int(point.y) - optionHeight * buttonNames.count / 2)
        self.frame = NSRect(origin: correctedPoint, size: self.frame.size)
    }
}
