//
//  CanvasController.swift
//  Collage
//
//  Created by Ivan Chistyakov on 26.08.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class CanvasController {
    let canvas: NSView
    let container: Container
    var popup: NSView
    var lock = false
    let menu = PopupMenu()
    var savedMouseLocation = NSPoint()
    var largestContainerWithPointInFrame: Container?
    var initPoint: NSPoint?
    let minSize: CGFloat = Container.minSize
    
    init(canvas: NSView) {
        self.canvas = canvas
        self.container = Container(border: Rectangle(fromNSRect: canvas.frame).framed(), outerView: canvas)
        let center = CGPoint(x: canvas.frame.midX, y: canvas.frame.midY)
        popup = menu.getView(at: center)
    }
    
    func click(_ location: NSPoint, byLeftMouse: Bool) {
        let center = CGPoint(x: canvas.frame.midX, y: canvas.frame.midY)
        popup = menu.getView(at: center)
        if lock == false && byLeftMouse == true {
            // do nothing
            return
        } else if lock == true && menu.getRectangle().checkIfContains(location) == true {
            let mode = menu.selectOption(location)
            container.click(savedMouseLocation, mode: mode)
            lock = false;
            popup.removeFromSuperview()
        } else if lock == true {
            // close menu
            popup.removeFromSuperview()
            lock = false
        } else if lock == false {
            canvas.addSubview(popup)
            lock = true
            savedMouseLocation = location
        }
    }
    
    // check if given point is located between main container and the canvas frames
    // or if it is inside main container's frame
    // to allow user to change main container's size
    func isInExtraSpace(location: NSPoint) -> Bool {
        if canvas.frame.contains(location) == false {
            return false
        }
        if self.container.border.framed().checkIfContains(location) == false {
            return true
        }
        return false
    }
    
    // find container that is maximally nested, containing given point
    func containsInFrame(_ location: NSPoint) -> Bool {
        if let object = self.container.largestContainerWithPointInFrame(location) {
            largestContainerWithPointInFrame = object
            initPoint = location
            return true
        }
        return false
    }
    
    func changeBorders(_ point: NSPoint) {
        if let largeContainer = largestContainerWithPointInFrame {
            switch largeContainer.position {
            case .right:
                if (point.x < largeContainer.border.second.x - minSize && point.x > largeContainer.brother()!.border.first.x + minSize) {
                    do {
                        try largeContainer.brother()?.checkAllOnRight(point)
                        try largeContainer.checkAllOnLeft(point)
                    } catch {
                        return
                    }
                    largeContainer.brother()?.changeAllOnRight(point)
                    largeContainer.changeAllOnLeft(point)
                    largeContainer.updateScrollView()
                    largeContainer.brother()?.updateScrollView()
                }
            case .left:
                if (point.x < largeContainer.brother()!.border.second.x - minSize && point.x > largeContainer.border.first.x + minSize) {
                    do {
                        try largeContainer.brother()?.checkAllOnLeft(point)
                        try largeContainer.checkAllOnRight(point)
                    } catch {
                        return
                    }
                    largeContainer.brother()?.changeAllOnLeft(point)
                    largeContainer.changeAllOnRight(point)
                    largeContainer.updateScrollView()
                    largeContainer.brother()?.updateScrollView()
                }
            case .bottom:
                if (point.y > largeContainer.border.first.y + minSize && point.y < largeContainer.brother()!.border.second.y - minSize) {
                    do {
                        try largeContainer.brother()?.checkAllOnBottom(point)
                        try largeContainer.checkAllOnTop(point)
                    } catch {
                        return
                    }
                    largeContainer.brother()?.changeAllOnBottom(point)
                    largeContainer.changeAllOnTop(point)
                    largeContainer.updateScrollView()
                    largeContainer.brother()?.updateScrollView()
                }
            case .top:
                if (point.y < largeContainer.border.second.y - minSize && point.y > largeContainer.brother()!.border.first.y + minSize ) {
                    do {
                        try largeContainer.brother()?.checkAllOnTop(point)
                        try largeContainer.checkAllOnBottom(point)
                    } catch {
                        return
                    }
                    largeContainer.brother()?.changeAllOnTop(point)
                    largeContainer.changeAllOnBottom(point)
                    largeContainer.updateScrollView()
                    largeContainer.brother()?.updateScrollView()
                }
            default:
                return
            }
        }
    }
    
    func stopMotion() {
        largestContainerWithPointInFrame = nil
    }
    
    func checkIfRearrangeIsPossible(_ cornerPoint: CGPoint) -> Bool {
        do {
            try self.container.checkAllOnRight(cornerPoint)
        } catch {
            print("Error: cannot move any further.")
            return false
        }
        return true
    }
    
    func rearrange(frame: Bool = false) {
        // if window changes, update only top/right containers
        let currentCorner = CGPoint(x: self.canvas.frame.maxX - Container.frameSize, y: self.canvas.frame.maxY - Container.frameSize)
        if frame == false {
            do {
                try self.container.checkAllOnRight(currentCorner)
                try self.container.checkAllOnTop(currentCorner)
            } catch {
                print("Error: cannot move any further.")
                return
            }
        }
        self.container.changeAllOnRight(currentCorner)
        self.container.changeAllOnTop(currentCorner)

        //if frame size changes, should also change bottom/left frames
        if frame == true {
            let anotherCorner = CGPoint(x: self.canvas.frame.minX + Container.frameSize, y: self.canvas.frame.minY + Container.frameSize)
            self.container.changeAllOnLeft(anotherCorner)
            self.container.changeAllOnBottom(anotherCorner)
        }
        self.container.updateScrollView()
    }
    
    func findMinWindowSize() -> CGPoint {
        let x = self.container.findMinWindowXSize()
        let y = self.container.findMinWindowYSize()
        return CGPoint(x: x, y: y)
    }
    
    func closeMenu() {
        if self.lock == true {
            self.click(NSPoint(), byLeftMouse: true)
        }
    }
}
