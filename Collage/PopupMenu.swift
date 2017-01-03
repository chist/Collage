//
//  PopupMenu.swift
//  Collage
//
//  Created by Ivan Chistyakov on 05.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa
/*
class PopUpMenuView: NSView {
    let buttonNames = ["splitVertically", "splitHorizontally", "merge", "choosePhoto"]
    let menuView = PopUpMenuView();
    let optionHeight: Int = 48
    let optionWidth: Int = 160
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.becomeFirstResponder()
        
        menuView.frame = NSRect(x: 0, y: 0, width: optionWidth, height: optionHeight * buttonNames.count)
        for i in 0...(buttonNames.count - 1) {
            let buttonView = NSImageView()
            buttonView.image = NSImage(named: buttonNames[i])
            buttonView.frame = NSRect(x: 0, y: i * optionHeight, width: optionWidth, height: optionHeight)
            buttonView.isEditable = false
            menuView.addSubview(buttonView)
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.becomeFirstResponder()
        
        menuView.frame = NSRect(x: 0, y: 0, width: optionWidth, height: optionHeight * buttonNames.count)
        for i in 0...(buttonNames.count - 1) {
            let buttonView = NSImageView()
            buttonView.image = NSImage(named: buttonNames[i])
            buttonView.frame = NSRect(x: 0, y: i * optionHeight, width: optionWidth, height: optionHeight)
            buttonView.isEditable = false
            menuView.addSubview(buttonView)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
    }
    
    func selectOption(_ mouseLocation: NSPoint) -> Int {
        return Int(mouseLocation.y - self.frame.minY) / optionHeight
    }
    
    // returns rectangle to check if user clicks menuButton
    func getRectangle() -> Rectangle {
        return Rectangle(fromNSRect: self.frame)
    }
    
    func getView(at point: CGPoint) -> NSView {
        let correctedPoint = CGPoint(x: Int(point.x) - optionWidth / 2,
                                     y: Int(point.y) - optionHeight * buttonNames.count / 2)
        self.menuView.frame = NSRect(origin: correctedPoint, size: self.menuView.frame.size)
        return menuView
    }
}*/

class PopupMenu {
    let buttonNames = ["splitVertically", "splitHorizontally", "merge", "choosePhoto"]
    let menuView = NSView();
    let optionHeight: Int = 48
    let optionWidth: Int = 160
    
    init() {
        menuView.frame = NSRect(x: 0, y: 0, width: optionWidth, height: optionHeight * buttonNames.count)
        for i in 0...(buttonNames.count - 1) {
            let buttonView = NSImageView()
            buttonView.image = NSImage(named: buttonNames[i])
            buttonView.frame = NSRect(x: 0, y: i * optionHeight, width: optionWidth, height: optionHeight)
            buttonView.isEditable = false
            menuView.addSubview(buttonView)
        }
    }
    
    func selectOption(_ mouseLocation: NSPoint) -> Int {
        return Int(mouseLocation.y - menuView.frame.minY) / optionHeight
    }
    
    // returns rectangle to check if user clicks menuButton
    func getRectangle() -> Rectangle {
        return Rectangle(fromNSRect: menuView.frame)
    }
    
    func getView(at point: CGPoint) -> NSView {
        let correctedPoint = CGPoint(x: Int(point.x) - optionWidth / 2,
                                     y: Int(point.y) - optionHeight * buttonNames.count / 2)
        self.menuView.frame = NSRect(origin: correctedPoint, size: self.menuView.frame.size)
        return menuView
    }
}
