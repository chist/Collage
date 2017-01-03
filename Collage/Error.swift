//
//  Error.swift
//  Collage
//
//  Created by Ivan Chistyakov on 07.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

enum ErrorType: Swift.Error {
    case borderViolation
    case unknownError
}

class Error {
    static let logViewFrame = NSRect(x: 0, y: 0, width: 300, height: 25)
    static var logSuperview: NSView?
    static let textField = NSTextField()
    
    static func setLogSuperview(view: NSView) {
        self.logSuperview = view
    }
    
    static func out(string: String) {
        if self.logSuperview == nil {
            print("No logSuperview found!")
            return
        }
        
        textField.frame = self.logViewFrame
        textField.stringValue = string
        textField.textColor = NSColor.black
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.isEditable = false
        textField.isSelectable = false
        textField.backgroundColor = NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        textField.isBordered = false
        textField.sizeToFit()
        logSuperview!.addSubview(textField)
    }
}
