//
//  Saver.swift
//  Collage
//
//  Created by Ivan Chistyakov on 27.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Saver {
    func save(view: NSView) {
        if let directoryPath = chooseDirectoryPath() {
            let image = view.snapshot
            let randNum = String(arc4random())
            let imageName = randNum + ".png"
            var imagePath = String(describing: directoryPath) + "/" + imageName
            imagePath = imagePath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!
            image.savePNG(imagePath)
        }
    }
    
    func chooseDirectoryPath() -> URL? {
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.canChooseDirectories = true
        myFileDialog.canChooseFiles = false
        if myFileDialog.runModal() == NSModalResponseCancel {
            return nil
        } else {
            return myFileDialog.url
        }
    }

    func getSnapshot(view: NSView) -> NSImage {
        return view.snapshot
    }
}

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    
    func savePNG(_ path:String) {
        do {
            if let url = URL(string: path) {
                try imagePNGRepresentation.write(to: url);
            } else {
                Error.out(string: "Error: path is underfined.");
            }
        } catch {
            Error.out(string: "Error saving collage.");
        }
    }
}

// gist.github.com/kaishin/d4df8fc6c701ca635e25
extension NSView {
    var snapshot: NSImage {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
        bitmapRep.size = bounds.size
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}

extension CGSize {
    func doubleScale() -> CGSize {
        return CGSize(width: width * 2, height: height * 2)
    }
}
