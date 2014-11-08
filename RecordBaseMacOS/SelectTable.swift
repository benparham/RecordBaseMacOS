//
//  SelectTable.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/7/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class SelectTable: NSObject {

    // ====================== Id Constants =====================
    // ----- Table
    let tableId: String = "selectTable"
    
    // ----- Columns
    let titleColumnId: String = "selectTitleColumn"
    let artistColumnId: String = "selectArtistColumn"
    let albumColumnId: String = "selectAlbumColumn"
    let yearColumnId: String = "selectYearColumn"
    
    // ----- Row
    let rowId: String = "selectRow"
    
    // ----- Cell
    let cellId: String = "selectCell"
    
    
    // ====================== Globals =====================
    let tableView: NSTableView
    let musicRoot: MDSMusic
    var songRoot: MDSSongContainer
    
    // ====================== Initializer =====================
    init(tableView: NSTableView, musicRoot: MDSMusic, songRoot: MDSSongContainer? = nil) {
        self.tableView = tableView
        self.musicRoot = musicRoot
        if songRoot != nil {
            self.songRoot = songRoot!
        } else {
            self.songRoot = self.musicRoot
        }
    }
    
    
    // ====================== Delegate/Datasource Methods =====================
    
    // Get number of rows in table
    func numberOfRowsInTableView() -> Int {
        return songRoot.numSongs
    }
    
    // Get view for a row
    func tableView(rowViewForRow row: Int) -> NSTableRowView? {
        
        var type: MDSDataType = .MDSSongType
        var dataId: MDSDataId = songRoot.getSong(idx: row).id
        
        var result = tableView.makeViewWithIdentifier(rowId, owner: self) as? MusicTableRowView
        
        if result == nil {
            result = MusicTableRowView(type: type, dataId: dataId)
        } else {
            result!.setId(type, dataId: dataId)
        }
        
        return result
    }
    
    // Get view for a cell
    func tableView(viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var rowView = tableView.rowViewAtRow(row, makeIfNecessary: false) as MusicTableRowView
        assert(rowView.type == MDSDataType.MDSSongType)
        
        var song: MDSSong = songRoot.getSong(songId: rowView.dataId as MDSSongId, ignoreAssert: false)
        
        var result = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView
        
        assert(result != nil)
        
        var text: String!
        switch tableColumn.identifier {
        case titleColumnId:
            text = song.title
        case artistColumnId:
            text = musicRoot.getArtist(artistId: song.artistId).name
        case albumColumnId:
            text = musicRoot.getAlbum(albumId: song.albumId).title
        case yearColumnId:
            text = "Not yet implemented"
        default:
            Helper.printError("Received request from unknown column")
            return nil
        }
        
        result!.textField?.stringValue = text
        
        return result
    }
    
    
    // ====================== User Action Response =====================
    
    // Respond to row selection
    func rowSelected() {
        println("Select table view selected, row: \(tableView.selectedRow)")
    }
    
    func updateSongRoot(newSongRoot: MDSSongContainer) {
        songRoot = newSongRoot
        tableView.reloadData()
    }
}
