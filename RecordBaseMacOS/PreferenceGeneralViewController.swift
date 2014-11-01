//
//  PreferenceViewGeneralController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/29/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class PreferenceGeneralViewController: NSViewController {
    
    var userDefaults: NSUserDefaults?
    
    @IBOutlet
    var urlLabel: NSTextField?
    
    @IBAction
    func chooseUrl(sender: AnyObject) {
        println("Allow location choice here")
        
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        
        openPanel.beginWithCompletionHandler { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                var storageUrl: NSURL = (openPanel.URLs as [NSURL])[0]
//                println("User has selected url: \(storageUrl.absoluteString)")
                
                self.userDefaults?.setURL(storageUrl, forKey: prefsKeyStorageUrl)
                self.updateUrlLabel()
            }
        }
    }
    
    @IBAction
    func help(sender: AnyObject) {
        println("Add help information here")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load user defaults
        userDefaults = NSUserDefaults.standardUserDefaults()
        assert(userDefaults != nil)
        
        updateUrlLabel()
    }
    
    func updateUrlLabel() {
        urlLabel?.stringValue = userDefaults!.URLForKey(prefsKeyStorageUrl)!.absoluteString!
    }
}
