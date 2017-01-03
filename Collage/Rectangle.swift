//
//  Rectangle.swift
//  Collage
//
//  Created by Ivan Chistyakov on 25.08.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Rectangle: NSObject {
    var first: CGPoint      // left bottom point
    var second: CGPoint     // right upper point
    
    var minX: CGFloat {
        return first.x
    }
    var minY: CGFloat {
        return first.y
    }
    var maxX: CGFloat {
        return second.x
    }
    var maxY: CGFloat {
        return second.y
    }
    var width: CGFloat {
        return second.x - first.x
    }
    var height: CGFloat {
        return second.y - first.y
    }
    
    init(first: CGPoint = CGPoint(), second: CGPoint = CGPoint()) throws {
        if (first.x > second.x) || (first.y > second.y) {
            print("Error: incorrect values to create rectangle!")
            throw NSError()
        }
        self.first = first; self.second = second
    }
    init(fromNSRect rect: NSRect) {
        first = CGPoint(x: Int(rect.minX), y: Int(rect.minY))
        second = CGPoint(x: Int(rect.maxX), y: Int(rect.maxY))
    }
    
    func toNSRect() -> NSRect {
        let newRect = NSRect(x: self.first.x, y: self.first.y, width: self.second.x - self.first.x, height: self.second.y - self.first.y)
        return newRect;
    }
    
    func leftHalf() -> Rectangle {
        let newRectangle: Rectangle = try! Rectangle(first: self.first, second:  self.second)
        newRectangle.second.x = (newRectangle.first.x + newRectangle.second.x) / 2
        return newRectangle
    }
    
    func rightHalf() -> Rectangle {
        let newRectangle: Rectangle = try! Rectangle(first: self.first, second:  self.second)
        newRectangle.first.x = (newRectangle.first.x + newRectangle.second.x) / 2
        return newRectangle
    }
    
    func topHalf() -> Rectangle {
        let newRectangle: Rectangle = try! Rectangle(first: self.first, second:  self.second)
        newRectangle.first.y = (newRectangle.first.y + newRectangle.second.y) / 2
        return newRectangle
    }
    
    func bottomHalf() -> Rectangle {
        let newRectangle: Rectangle = try! Rectangle(first: self.first, second:  self.second)
        newRectangle.second.y = (newRectangle.first.y + newRectangle.second.y) / 2
        return newRectangle
    }

    func framed() -> Rectangle {
        let newRectangle: Rectangle = try! Rectangle(first: self.first, second:  self.second)
        newRectangle.first.x  += Container.frameSize
        newRectangle.first.y  += Container.frameSize
        newRectangle.second.x -= Container.frameSize
        newRectangle.second.y -= Container.frameSize
        return newRectangle
    }

    func checkIfContains(_ point: NSPoint) -> Bool {
        if point.x > self.first.x && point.x < self.second.x &&
            point.y > self.first.y && point.y < self.second.y {
            return true
        }
        return false
    }
    
    func getCenter() -> NSPoint {
        return NSPoint(x: (first.x + second.x) / 2, y: (first.y + second.y) / 2)
    }
}
