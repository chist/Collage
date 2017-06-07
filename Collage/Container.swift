//
//  Container.swift
//  Collage
//
//  Created by Ivan Chistyakov on 25.08.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa
import Quartz

class Container {
    var outerView: NSView
    var isImage: Bool = false
    var image: NSImage?
    var scrollView: MutableScrollView?
    var imageView: IKImageView?
    var isVertical: Bool = true
    var firstContainer: Container?
    var secondContainer: Container?
    var parentContainer: Container?
    var border: Rectangle
    var position: Position {
        if let otherBorder = self.brother()?.border {
            if otherBorder.maxY == self.border.maxY {
                if otherBorder.maxX < self.border.maxX {
                    return Position.right
                } else {
                    return Position.left
                }
            } else if otherBorder.maxY > self.border.maxY {
                return Position.bottom
            } else {
                return Position.top
            }
        }
        return Position.undefined
    }
    static let minSize: CGFloat = 80
    static let defaultImageQuantity = 10
    static var frameSize: CGFloat = 7

    init(border: Rectangle, outerView: NSView, image: NSImage? = NSImage.init(named: "Non-existing image")) {
        isImage = true
        self.border = border
        self.outerView = outerView
        
        if let img = image {
            self.image = img
        } else {
            self.image = getRandomImage()
        }
        
        if let image = self.image {
            self.scrollView = MutableScrollView(image: image, border: self.border)
            outerView.addSubview(self.scrollView!)
        } else {
            print("Error: image not found.")
        }
    }
    
    func makeChildren(vertical isVertical: Bool) {
        if isVertical && self.border.width < 2 * Container.minSize {
            print("Frame is too small to be divided!")
            return
        }
        if isVertical == false && self.border.height < 2 * Container.minSize {
            print("Frame is too small to be divided!")
            return
        }
        
        self.isImage = false
        self.scrollView?.removeFromSuperview()
        
        var image1: NSImage, image2: NSImage
        let cur_img: NSImage? = self.scrollView?.content.image
        if cur_img?.name()?.hasPrefix("default") == true {
            image1 = getRandomImage()
            image2 = getRandomImage()
        } else {
            image1 = cur_img!
            image2 = cur_img!
        }
        
        if isVertical {
            self.isVertical = true
            self.firstContainer = Container(border: border.leftHalf(), outerView: outerView, image: image1)
            self.secondContainer = Container(border: border.rightHalf(), outerView: outerView, image: image2)
        } else {
            self.isVertical = false
            self.firstContainer = Container(border: border.topHalf(), outerView: outerView, image: image1)
            self.secondContainer = Container(border: border.bottomHalf(), outerView: outerView, image: image2)
        }
        
        self.firstContainer!.parentContainer = self
        self.secondContainer!.parentContainer = self
    }
    
    func brother() -> Container? {
        if let parent = self.parentContainer {
            if parent.firstContainer === self {
                return parent.secondContainer
            } else {
                return parent.firstContainer
            }
        }
        return nil
    }
    
    func click(_ location: CGPoint, mode: Int) {
        let selected = searchDeepestContainer(location, inContainer: self)
        switch mode {
        case 0:
            selected.makeChildren(vertical: true)
        case 1:
            selected.makeChildren(vertical: false)
        case 2:
             if let parent = selected.parentContainer {
                parent.image = selected.image
                parent.removeSubviews()
                parent.firstContainer = nil
                parent.secondContainer = nil
                parent.isImage = true
                parent.scrollView = MutableScrollView(image: parent.image!, border: parent.border)
                outerView.addSubview(parent.scrollView!)
             } else {
                 print("Error: no layer to merge with")
             }
        case 3:
            let myFileDialog: NSOpenPanel = NSOpenPanel()
            myFileDialog.runModal()
            if let url = myFileDialog.url {
                selected.image = NSImage(byReferencing: url)
            }
            if selected.image == nil {
                if let prevImage = self.image {
                    selected.image = prevImage
                } else {
                    selected.image = getRandomImage()
                }
            }
            
            selected.scrollView?.removeFromSuperview()
            selected.scrollView = MutableScrollView(image: selected.image!, border: selected.border)
            outerView.addSubview(selected.scrollView!)
        default:
            return
        }
    }
    
    func searchDeepestContainer(_ location: CGPoint, inContainer currentContainer: Container) -> Container {
        if currentContainer.isImage == true {
            return currentContainer
        }
        if currentContainer.isVertical {
            if location.x > currentContainer.secondContainer!.border.minX {
                return searchDeepestContainer(location, inContainer: currentContainer.secondContainer!)
            } else {
                return searchDeepestContainer(location, inContainer: currentContainer.firstContainer!)
            }
        } else {
            if location.y > currentContainer.firstContainer!.border.minY {
                return searchDeepestContainer(location, inContainer: currentContainer.firstContainer!)
            } else {
                return searchDeepestContainer(location, inContainer: currentContainer.secondContainer!)
            }
        }
    }
    
    func removeSubviews() {
        self.firstContainer?.removeSubviews()
        self.secondContainer?.removeSubviews()
        if self.isImage == true {
            self.scrollView?.removeFromSuperview()
        }
    }
    
    func largestContainerWithPointInFrame(_ location: NSPoint) -> Container? {
        if self.border.checkIfContains(location) == true && self.border.framed().checkIfContains(location) == false {
            return self
        }
        if let object = self.firstContainer?.largestContainerWithPointInFrame(location) {
            return object
        }
        if let object = self.secondContainer?.largestContainerWithPointInFrame(location) {
            return object
        }
        return nil
    }
    
    func checkAllOnLeft(_ diff: CGPoint) throws {
        if self.isVertical {
            if let leftChild = self.firstContainer {
                if diff.x > leftChild.border.second.x - Container.minSize {
                    throw ErrorType.borderViolation
                }
                do {
                    try leftChild.checkAllOnLeft(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        } else {
            if let topChild = self.firstContainer, let bottomChild = self.secondContainer {
                do {
                    try topChild.checkAllOnLeft(diff)
                    try bottomChild.checkAllOnLeft(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        }
    }
    
    func checkAllOnRight(_ diff: CGPoint) throws {
        if self.isVertical {
            if let rightChild = self.secondContainer {
                if diff.x < rightChild.border.first.x + Container.minSize {
                    throw ErrorType.borderViolation
                }
                do {
                    try rightChild.checkAllOnRight(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        } else {
            if let topChild = self.firstContainer, let bottomChild = self.secondContainer {
                do {
                    try topChild.checkAllOnRight(diff)
                    try bottomChild.checkAllOnRight(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        }
    }
    
    func checkAllOnTop(_ diff: CGPoint) throws {
        if self.isVertical == false {
            if let topChild = self.firstContainer {
                if diff.y < topChild.border.first.y + Container.minSize {
                    throw ErrorType.borderViolation
                }
                do {
                    try topChild.checkAllOnTop(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        } else {
            if let leftChild = self.firstContainer, let rightChild = self.secondContainer {
                do {
                    try leftChild.checkAllOnTop(diff)
                    try rightChild.checkAllOnTop(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        }
    }
    
    func checkAllOnBottom(_ diff: CGPoint) throws {
        if self.isVertical == false {
            if let bottomChild = self.secondContainer {
                if diff.y > bottomChild.border.second.y - Container.minSize {
                    throw ErrorType.borderViolation
                }
                do {
                    try bottomChild.checkAllOnBottom(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        } else {
            if let leftChild = self.firstContainer, let rightChild = self.secondContainer {
                do {
                    try leftChild.checkAllOnBottom(diff)
                    try rightChild.checkAllOnBottom(diff)
                } catch (ErrorType.borderViolation) {
                    throw ErrorType.borderViolation
                }
            }
        }
    }
    
    func changeAllOnLeft(_ diff: CGPoint) {
        if self.isVertical {
            if let leftChild = self.firstContainer {
                leftChild.changeAllOnLeft(diff)
                leftChild.border.first.x = diff.x
            }
        } else {
            if let topChild = self.firstContainer, let bottomChild = self.secondContainer {
                topChild.changeAllOnLeft(diff)
                bottomChild.changeAllOnLeft(diff)
                topChild.border.first.x = diff.x
                bottomChild.border.first.x = diff.x
            }
        }
        self.border.first.x = diff.x
    }
    
    func changeAllOnRight(_ diff: CGPoint) {
        if self.isVertical {
            if let rightChild = self.secondContainer {
                rightChild.changeAllOnRight(diff)
                rightChild.border.second.x = diff.x
            }
        } else {
            if let topChild = self.firstContainer, let bottomChild = self.secondContainer {
                topChild.changeAllOnRight(diff)
                bottomChild.changeAllOnRight(diff)
                topChild.border.second.x = diff.x
                bottomChild.border.second.x = diff.x
            }
        }
        self.border.second.x = diff.x
    }
    
    func changeAllOnTop(_ diff: CGPoint) {
        if self.isVertical == false {
            if let topChild = self.firstContainer {
                topChild.changeAllOnTop(diff)
                topChild.border.second.y = diff.y
            }
        } else {
            if let leftChild = self.firstContainer, let rightChild = self.secondContainer {
                leftChild.changeAllOnTop(diff)
                rightChild.changeAllOnTop(diff)
                leftChild.border.second.y = diff.y
                rightChild.border.second.y = diff.y
            }
        }
        self.border.second.y = diff.y
    }
    
    func changeAllOnBottom(_ diff: CGPoint) {
        if self.isVertical == false {
            if let bottomChild = self.secondContainer {
                bottomChild.changeAllOnBottom(diff)
                bottomChild.border.first.y = diff.y
            }
        } else {
            if let leftChild = self.firstContainer, let rightChild = self.secondContainer {
                leftChild.changeAllOnBottom(diff)
                rightChild.changeAllOnBottom(diff)
                leftChild.border.first.y = diff.y
                rightChild.border.first.y = diff.y
            }
        }
        self.border.first.y = diff.y
    }

    func findMinWindowXSize() -> CGFloat {
        if self.secondContainer == nil {
            return self.border.minX + Container.minSize
        }
        if self.isVertical {
            return self.secondContainer!.findMinWindowXSize()
        } else {
            return max(self.firstContainer!.findMinWindowXSize(), self.secondContainer!.findMinWindowXSize())
        }
    }
    
    func findMinWindowYSize() -> CGFloat {
        if self.firstContainer == nil {
            return self.border.minY + Container.minSize
        }
        if self.isVertical == false {
            return self.firstContainer!.findMinWindowYSize()
        } else {
            return max(self.firstContainer!.findMinWindowYSize(), self.secondContainer!.findMinWindowYSize())
        }
    }
    
    func updateScrollView() {
        if (isImage == false) {
            self.firstContainer?.updateScrollView()
            self.secondContainer?.updateScrollView()
            return
        }
        scrollView?.update()
    }
}

func getRandomImage() -> NSImage {
    let num = arc4random() % UInt32(Container.defaultImageQuantity)
    let name: String = "default\(num)"
    return NSImage(named: name)!
}
