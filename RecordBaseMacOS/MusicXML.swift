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

    /*class*/ func fetchMusicDataFromXML() -> ([String : MDSArtist], [String : MDSAlbum], [String : MDSSong])? {
            
        // Get path to XML file
        var xmlPathUrl: NSURL = getMusicXMLPathURL()
        
        // Convert file to NSXMLDocument
        var error: NSError? = nil
        if var document: NSXMLDocument = NSXMLDocument(contentsOfURL: xmlPathUrl, options: 0, error: &error) {
            
            assert(document.DTD != nil)
            
            // Build music data structures from document
            if var rootElement: NSXMLElement = document.rootElement() {
                musicRoot = MDSMusic(musicElement: rootElement)
                let iter: MDSIterator<MDSSong> = musicRoot!.getSongs()
                var curAlbum: MDSSong? = iter.next()
                while curAlbum != nil {
                    println("Item: \(curAlbum!.title)")
                    curAlbum = iter.next()
                }
            } else {
                Helper.printError("Failed to get root 'music' element from document")
            }

            
            
            //            var count: Int = 1
//            // Iterate over all nodes in document order
//            while node != nil {
//                if node!.kind == NSXMLNodeKind.NSXMLElementKind {
//                    println("Node \(count): \(node!.name) -> \(node!.objectValue)")
//                    count += 1
//                }
//                
//                node = node!.nextNode
//            }
            
        } else {
            Helper.printError("Failed to convert xml path to NSXMLDocument", error: error)
            return nil
        }
        
        return nil
    }
//}