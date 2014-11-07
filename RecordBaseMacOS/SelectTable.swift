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
    
    
    // ====================== Initializer =====================
    init(tableView: NSTableView, musicRoot: MDSMusic) {
        self.tableView = tableView
        self.musicRoot = musicRoot
    }
    
    
    // ====================== Delegate/Datasource Methods =====================
    
    // Get number of rows in table
    func numberOfRowsInTableView() -> Int {
        return musicRoot.numSongs
    }
    
    // Get view for a row
    func tableView(rowViewForRow row: Int) -> NSTableRowView? {
        
        var type: MDSDataType = .MDSSongType
        var dataId: MDSDataId = musicRoot.getSong(idx: row).id
        
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
        
        var song: MDSSong = musicRoot.getSong(songId: rowView.dataId as MDSSongId)
        
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
}
