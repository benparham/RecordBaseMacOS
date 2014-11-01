//
//  AppDelegate.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/27/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Load initial defaults from plist file
        if let defaultPrefsPath = NSBundle.mainBundle().pathForResource("defaultPrefs", ofType: "plist") {
            var defaultPrefsDict: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: defaultPrefsPath)
            
            // Add in default involving home directory dynamically
            defaultPrefsDict!.setValue(NSHomeDirectory() + "/Documents", forKey: prefsKeyStorageUrl)
            
//            // For testing, remove user preferences for items in dictionary upon app startup
//            var enumerator: NSEnumerator = defaultPrefsDict!.keyEnumerator()
//            var key: String? = enumerator.nextObject() as? String
//            while key != nil {
//                userDefaults.removeObjectForKey(key!)
//                key = enumerator.nextObject() as? String
//            }
            
            userDefaults.registerDefaults(defaultPrefsDict!)
        } else {
            println("Could not find defaultPrefs plist file")
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        
        println("Request to open files not yet supported")
        
        NSApplication.sharedApplication().replyToOpenOrPrint(NSApplicationDelegateReply(rawValue: 2)!)
    }

}

