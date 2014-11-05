//
//  MainViewController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/30/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var filterTableId: String?
    var selectTableId: String?
    
    @IBOutlet
    var filterTableView: NSTableView?
    
    @IBOutlet
    var selectTableView: NSTableView?
    
    // Contains all music data once initialized
    var musicRoot: MDSMusic?
    
    // ====================== Controller =====================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTableId = filterTableView?.identifier
        selectTableId = selectTableView?.identifier
        
        musicRoot = fetchMusicDataFromXML()
        assert(musicRoot != nil)
    }
    
    
    
    // ====================== Delegate/DataSource =====================
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView.identifier {
            case filterTableId!:
                return numberOfRowsInFilterTableView()
            case selectTableId!:
                return numberOfRowsInSelectTableView()
            default:
                Helper.printError("Delegate received request from unknown tableView")
        }
        
        return 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        assert(tableColumn != nil)
        
        switch tableView.identifier {
        case filterTableId!:
            return filterTableView(tableView, viewForTableColumn: tableColumn!, row: row)
        case selectTableId!:
            return selectTableView(tableView, viewForTableColumn: tableColumn!, row: row)
        default:
            Helper.printError("Delegate received request from unknown tableView")
        }
        
        return nil
    }
    
    
    
    // ====================== Filter Table =====================
    
    func numberOfRowsInFilterTableView() -> Int {
        return 5
    }
    
    func filterTableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var result = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView
        
        assert(result != nil)
        
        result!.textField?.stringValue = "filter table item"
        
        return result
    }
    
    
    
    // ====================== Select Table =====================
    
    func numberOfRowsInSelectTableView() -> Int {
        return musicRoot!.getNumSongs()
    }
    
    func selectTableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var result = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView
        
        assert(result != nil)
        
        var song = musicRoot!.getSong(idx: row)
        var text: String?
        switch tableColumn.identifier {
            case "columnTitle":
                text = song.title
            case "columnArtist":
                text = musicRoot!.getArtist(artistId: song.getArtistId()).name
            case "columnAlbum":
                text = musicRoot!.getAlbum(albumId: song.getAlbumId()).title
            case "columnYear":
//                text = musicRoot!.getAlbum(albumId: song.getAlbumId()).year
                text = "Not yet implemented"
            default:
                Helper.printError("Received request from unknown column")
                text = nil
        }
        
        if (text != nil) {
            result!.textField?.stringValue = text!
        } else {
            result = nil
        }
        
        return result
    }
    
}