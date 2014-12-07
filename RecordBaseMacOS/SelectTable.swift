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
    var musicRoot: MDSSongContainer
    
    // ====================== Initializer =====================
    init(tableView: NSTableView, musicRoot: MDSSongContainer) {
        self.tableView = tableView
        self.musicRoot = musicRoot
        
        tableView.doubleAction = "doubleClick:"
    }
    
    
    func doubleClick(sender: AnyObject?) {
        println("Double click test successfull")
    }
    
    
    // ====================== Delegate/Datasource Methods =====================
    
    // Get number of rows in table
    func numberOfRowsInTableView() -> Int {
        return musicRoot.numSongs
    }
    
    // Get view for a row
    func tableView(rowViewForRow row: Int) -> NSTableRowView? {
        
//        var type: MDSDataType = .MDSSongType
//        var dataId: MDSDataId = songRoot.getSong(idx: row).id
        
        var song: MDSSong = musicRoot.getSong(idx: row)
        
        var result = tableView.makeViewWithIdentifier(rowId, owner: self) as? SelectTableRowView
        
//        if result == nil {
//            result = MusicTableRowView(type: type, dataId: dataId)
//        } else {
//            result!.setId(type, dataId: dataId)
//        }
        if result == nil {
            result = SelectTableRowView(data: song)
        } else {
            result!.data = song
        }
        
        return result
    }
    
    // Get view for a cell
    func tableView(viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var rowView = tableView.rowViewAtRow(row, makeIfNecessary: false) as SelectTableRowView
        
        assert(rowView.data.type == MDSDataType.MDSSongType)
        var song: MDSSong = rowView.data as MDSSong
        
        var result = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView
        assert(result != nil)
        
        var text: String!
        switch tableColumn.identifier {
            case titleColumnId:
                text = song.title
            case artistColumnId:
//                text = musicRoot.getArtist(artistId: song.artistId).name
                text = song.artist.name
            case albumColumnId:
//                text = musicRoot.getAlbum(albumId: song.albumId).title
                text = song.album.title
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

    func getSelectedSong() -> MDSSong? {
        if tableView.selectedRow < 0 {
            return nil
        }
        
        var selectedRow = tableView.rowViewAtRow(tableView.selectedRow, makeIfNecessary: false) as SelectTableRowView
        
        return selectedRow.data
    }
    
    func updateMusicRoot(newRoot: MDSSongContainer) {
        musicRoot = newRoot
        tableView.reloadData()
    }
}
