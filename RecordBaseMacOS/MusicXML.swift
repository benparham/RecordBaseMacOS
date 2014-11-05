//
//  MyXML.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Foundation

//class MusicXML {

    var musicRoot: MDSMusic? = nil

    /*class*/ let musicXmlFileName: String = "music.xml"

    /*class*/ func getMusicXMLPathURL() -> NSURL {
        return NSUserDefaults.standardUserDefaults().URLForKey(prefsKeyStorageUrl)!.URLByAppendingPathComponent(musicXmlFileName)
    }

    /*class*/ func fetchMusicDataFromXML() -> MDSMusic? {
        
        var result: MDSMusic? = nil
        
        // Get path to XML file
        var xmlPathUrl: NSURL = getMusicXMLPathURL()
        
        // Convert file to NSXMLDocument
        var error: NSError? = nil
        if var document: NSXMLDocument = NSXMLDocument(contentsOfURL: xmlPathUrl, options: 0, error: &error) {
            
            assert(document.DTD != nil)
            
            // Build music data structures from document
            if var rootElement: NSXMLElement = document.rootElement() {
                result = MDSMusic(musicElement: rootElement)
//                let iter: MDSIterator<MDSSong> = musicRoot!.getSongs()
//                var curAlbum: MDSSong? = iter.next()
//                while curAlbum != nil {
//                    println("Item: \(curAlbum!.title)")
//                    curAlbum = iter.next()
//                }
            } else {
                Helper.printError("Failed to get root 'music' element from document")
            }
        } else {
            Helper.printError("Failed to convert xml path to NSXMLDocument", error: error)
        }
        
        return result
    }
//}