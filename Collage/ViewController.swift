//
//  ViewController.swift
//  Collage
//
//  Created by Ivan Chistyakov on 25.08.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Cocoa
import Foundation

enum Position {
    case left
    case right
    case top
    case bottom
    case undefined
}

class ViewController: NSViewController {
    let menuSize: CGFloat = 200
    let minCanvasXSize: CGFloat = 300
    let minCanvasYSize: CGFloat = 500
    var count: Int = 0
    var savedCount: Int = 0
    
    // minimum window size
    var xConstraint: CGFloat = 500
    var yConstraint: CGFloat = 500
    // maximum window size defined in storyboard
    
    var canvasController: CanvasController?
    var help: Help?
    let saver = Saver()
    
    @IBOutlet var canvas: NSView!
    @IBOutlet var menuView: NSView!
    @IBOutlet var menuButton: NSButton!
    @IBOutlet var menuBackground: NSImageView!
    @IBOutlet var frameWidthSlider: NSSliderCell!
    @IBOutlet var colorPanel: NSImageView!
    
    var mouseLocation: NSPoint {
        var windowLocation = NSEvent.mouseLocation()
        windowLocation.x -= (self.view.window?.frame.minX)!
        windowLocation.y -= (self.view.window?.frame.minY)!
        return windowLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canvas.layer?.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        canvasController = CanvasController(canvas: canvas)
        Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(detectMouseDrag), userInfo: nil, repeats: true)
        help = Help(superView: self.canvas)
        
        self.view.window?.isRestorable = false
    }
    
    override func mouseDown(with event: NSEvent) {
        if actionStarted {
            actionStarted = false
            count = 0;
        }
        help?.hide()
        
        // if user changes frame color
        let point = NSPoint(x: mouseLocation.x - canvas.frame.width, y: mouseLocation.y)
        if colorPanel.frame.contains(point) {
            let center = NSPoint(x: colorPanel.frame.width / 2, y: colorPanel.frame.height / 2)
            let insidePoint = NSPoint(x: point.x - colorPanel.frame.minX, y: point.y - colorPanel.frame.minY)
            let curRadius = distance(first: center, second: insidePoint)
            if curRadius > colorPanel.frame.width / 2 {
                return
            }
            let h = (atan2(-insidePoint.x + center.x, -insidePoint.y + center.y) + CGFloat.pi) / (2 * CGFloat.pi)
            let color = NSColor.init(hue: h, saturation: curRadius / center.y, brightness: 1, alpha: 1)
            self.canvas.layer?.backgroundColor = color.cgColor
        }
        
        if self.canvas.frame.contains(mouseLocation) {
            canvasController?.click(mouseLocation, byLeftMouse: true)
            updateConstrains()
        }
    }
 
    override func rightMouseDown(with event: NSEvent) {
        self.becomeFirstResponder()
        
        Swift.print(self.acceptsFirstResponder)
        //self.perform(#selector(NSResponder.becomeFirstResponder), with: self, afterDelay: 0)
        
        if self.canvas.frame.contains(mouseLocation) {
            updateConstrains()
            canvasController?.click(mouseLocation, byLeftMouse: false)
            help?.hide()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        count += 1
    }
    
    override func mouseUp(with event: NSEvent) {
        if actionStarted {
            actionStarted = false
            count = 0
            startedInExtra = false
            isTracking = false
        }
        updateConstrains()
    }
 
    var isTracking = false
    var actionStarted = false
    var locationStarted = NSPoint()
    var startedInExtra = false;
    var position = Position.right
    
    func detectMouseDrag() {
        if actionStarted == false && mouseLocation.x > self.view.frame.width - menuSize {
            return
        }
        if count > savedCount {
            // start tracking
            if (actionStarted == false) {
                locationStarted = mouseLocation
                // because there is distance between window borders
                // and main container (for the purpose of equal frame sizes),
                // we need to check separately if given point is inside those extra space
                if canvasController!.isInExtraSpace(location: mouseLocation) {
                    if mouseLocation.x > canvas.frame.width - 2 * Container.frameSize {
                        position = Position.right
                    } else if mouseLocation.x < 2 * Container.frameSize {
                        position = Position.left
                    } else if mouseLocation.y < 2 * Container.frameSize {
                        position = Position.bottom
                    } else if mouseLocation.y > canvas.frame.height - 2 * Container.frameSize {
                        position = Position.top
                    }
                    startedInExtra = true
                    isTracking = true
                } else if canvasController!.containsInFrame(mouseLocation) {
                    startedInExtra = false
                    isTracking = true
                }
                actionStarted = true
            }
            if isTracking {
                // if size of main container changes, we need to resize window
                if startedInExtra {
                    let curFrame = self.view.window!.frame
                    let windowFrame: NSRect
                    switch position {
                    case .right:
                        windowFrame = NSRect(x: curFrame.minX, y: curFrame.minY,
                                             width: mouseLocation.x + menuSize, height: curFrame.height)
                    case .left:
                        windowFrame = NSRect(x: curFrame.minX + mouseLocation.x, y: curFrame.minY,
                                             width: curFrame.width - mouseLocation.x, height: curFrame.height)
                    case .bottom:
                        windowFrame = NSRect(x: curFrame.minX, y: curFrame.minY + mouseLocation.y,
                                             width: curFrame.width, height: curFrame.height - mouseLocation.y)
                    case .top:
                        windowFrame = NSRect(x: curFrame.minX, y: curFrame.minY,
                                             width: curFrame.width, height: mouseLocation.y)
                    default:
                        return
                    }
                    
                    // check if suggested window frame is OK
                    // minSize and maxSize are determined with respect to containers' constraints
                    if  self.view.window!.minSize.width  > windowFrame.width  ||
                        self.view.window!.maxSize.width  < windowFrame.width  ||
                        self.view.window!.minSize.height > windowFrame.height ||
                        self.view.window!.maxSize.height < windowFrame.height
                    {
                        savedCount = count
                        return
                    }
                    
                    self.view.window?.setFrame(windowFrame, display: true)
                    // viewDidLayout is called automatically
                }
                else {
                    canvasController?.changeBorders(mouseLocation)
                }
            }
        }
        savedCount = count
    }
    
    func updateConstrains() {
        if let canvasController = canvasController {
            let minCorner: CGPoint = canvasController.findMinWindowSize()
            self.xConstraint = max(minCorner.x + Container.frameSize, self.minCanvasXSize) + menuSize
            self.yConstraint = max(minCorner.y + Container.frameSize, self.minCanvasYSize)
        }
        self.view.window?.minSize = CGSize(width: xConstraint, height: yConstraint)
        self.view.window?.contentMinSize = CGSize(width: xConstraint, height: yConstraint)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        canvasController?.closeMenu()
        help?.hide()
        
        // resize canvas and its subviews
        self.canvas.frame = NSRect(x: 0, y: 0, width: self.view.frame.width - self.menuSize, height: self.view.frame.height)
        self.view.setFrameOrigin(NSPoint(x: 0, y: 0))
        if let canvasController = canvasController {
            canvasController.container.border.first.x = Container.frameSize
            canvasController.container.border.first.y = Container.frameSize
            canvasController.container.border.second.x = canvas.frame.maxX - Container.frameSize
            canvasController.container.border.second.y = canvas.frame.maxY - Container.frameSize
            canvasController.rearrange()
        }
        
        // resize menu
        self.menuView.frame = NSRect(x: 0, y: 0, width: self.menuSize, height: self.canvas.frame.maxY)
        self.menuView.setFrameOrigin(NSPoint(x: self.view.frame.maxX - self.menuSize, y: 0))
        self.menuBackground.frame = NSRect(x: 0, y: 0, width: self.menuSize, height: self.canvas.frame.maxY)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        canvasController?.closeMenu()
        help?.hide()
        saver.save(view: self.canvas)
    }
    
    @IBAction func frameWidthSliderChanged(_ sender: AnyObject) {
        Container.frameSize = CGFloat(frameWidthSlider.doubleValue)
        self.canvasController?.rearrange(frame: true)
    }
    
    @IBAction func shareOnSocialNetwork(_ sender: NSButton) {
        help?.hide()
        canvasController?.closeMenu()
        let text = "I made a beautiful picture using this Collage app!"
        let content: [Any] = [text, saver.getSnapshot(view: self.canvas)]
        switch sender.tag {
        case 0:
            NSSharingService.init(named: NSSharingServiceNamePostOnTwitter)?.perform(withItems: content)
        case 1:
            NSSharingService.init(named: NSSharingServiceNamePostOnFacebook)?.perform(withItems: content)
        default:
            return
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: NSButton) {
        canvasController?.closeMenu()
        help?.changeState()
    }
}

func distance(first: CGPoint, second: CGPoint) -> CGFloat {
    return sqrt((first.x - second.x) * (first.x - second.x) + (first.y - second.y) * (first.y - second.y))
}
