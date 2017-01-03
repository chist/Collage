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
    var directoryPath: String
    var imagePath: String = "0.png"
    
    init() {
        directoryPath = NSString(string: "~/Documents/").expandingTildeInPath
        let manager = FileManager.default
        do {
            try manager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error: can't create directory.")
        }
    }
    
    func save(view: NSView) {
        let image = view.snapshot
        updateImagePath()
        image.savePNG(imagePath)
    }
    
    func getSnapshot(view: NSView) -> NSImage {
        return view.snapshot
    }
    
    func updateDirectoryPath() {
        if let path = UserDefaults.standard.object(forKey: "savingPath") {
            print(path)
            directoryPath = (path as! NSString).expandingTildeInPath
            print(directoryPath)
        }
    }
    
    func updateImagePath() {
        updateDirectoryPath()
        let randNum = String(arc4random())
        let imageName = randNum + ".png"
        imagePath = directoryPath + "/" + imageName
        imagePath = imagePath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!
        print("imagePath: ", imagePath)
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
                print("Error saving collage: path is underfined.");
            }
        } catch {
            print("Error saving collage.");
        }
    }
}

extension NSView {
    var snapshot: NSImage {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage()
        image.addRepresentation(bitmapRep)
        bitmapRep.size = bounds.size.doubleScale()
        return image
    }
}

extension CGSize {
    func doubleScale() -> CGSize {
        return CGSize(width: width * 2, height: height * 2)
    }
}
