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

class Error: NSObject {
    static let logViewFrame = NSRect(x: 0, y: 0, width: 300, height: 25)
    static var logSuperview: NSView?
    static let textField = NSTextField()
    static let removeTime = 3
    
    static func setLogSuperview(view: NSView) {
        self.logSuperview = view
    }
    
    static func out(string: String) {
        if self.logSuperview == nil {
            print("No logSuperview found!")
            return
        }
        textField.frame = self.logViewFrame
        
        Error.textField.textColor = NSColor.black
        Error.textField.font = NSFont.systemFont(ofSize: 16)
        Error.textField.isEditable = false
        Error.textField.isSelectable = false
        
        textField.stringValue = string
        
        if textField.superview == nil {
            logSuperview!.addSubview(textField)
        }
        
        Timer.scheduledTimer(timeInterval: TimeInterval(removeTime), target: self, selector: #selector(removeMessage), userInfo: nil, repeats: false)
    }
    
    
    static func removeMessage() {
        Error.textField.removeFromSuperview()
    }
}
