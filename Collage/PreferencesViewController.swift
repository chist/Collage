//
//  PreferencesViewController.swift
//  Collage
//
//  Created by Ivan Chistyakov on 27.09.16.
//  Copyright © 2016 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa
import Social

class PreferencesViewController: NSViewController {

    @IBOutlet var chooseDirectoryButton: NSPopUpButton!
    
    override func viewDidLoad() {
        if let path = UserDefaults.standard.object(forKey: "savingPath") {
            print(path)
            chooseDirectoryButton.item(at: 0)?.title = cutPathName(string: path as! String)
        } else {
            chooseDirectoryButton.item(at: 0)?.title = "Documents"
        }
    }
    
    @IBAction func chooseDirectoryButtonPressed(_ sender: NSPopUpButton) {
        let defaults = UserDefaults.standard
        
        // if user wants to choose default folder
        if sender.selectedItem == sender.item(at: 1) {
            let myFileDialog: NSOpenPanel = NSOpenPanel()
            myFileDialog.canChooseDirectories = true
            myFileDialog.canChooseFiles = false
            myFileDialog.runModal()
            if let url = myFileDialog.url {
                print(url.path)
                defaults.set(url, forKey: "savingPath")
                let object = cutPathName(string: url.path)
                sender.item(at: sender.indexOfItem(withTag: 0))?.title = object
                sender.selectItem(at: 0)
            }
        }
    }
    
    func cutPathName(string: String) -> String {
        let str = string as NSString
        for i in stride(from: str.length - 2, to: 0, by: -1) {
            if str.substring(with: NSMakeRange(i, 1)) == "/" {
                let pre_res = str.substring(from: i + 1) as NSString
                // remove '/' in the end if needed
                if str.substring(with: NSMakeRange(str.length - 1, 1)) == "/" {
                    return pre_res.substring(to: pre_res.length - 1)
                } else {
                    return pre_res as String
                }
            }
        }
        return string as String
    }
}
