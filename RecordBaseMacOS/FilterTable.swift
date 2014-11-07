//
//  FilterTable.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/7/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class FilterTable: NSObject {

    // ====================== Id Constants =====================
    // ----- Tables
    let tableId: String = "filterTable"
    
    // ----- Columns
    let columnId: String = "filterColumn"
    
    // ----- Rows
    let rowId: String = "filterRow"
    
    // ----- Cells
    let cellId: String = "filterCell"
    
    
    // ====================== Globals =====================
    let tableView: NSTableView
    let musicRoot: MDSMusic
    
    enum FilterOption: Int {
        case None = 0
        case Artist = 1
        case Album = 2
    }
    
    var curFilterOption: FilterOption = .None
    
    
    // ====================== Initializer =====================
    init(tableView: NSTableView, musicRoot: MDSMusic) {
        self.tableView = tableView
        self.musicRoot = musicRoot
    }
    
    // ====================== Delegate/Datasource Methods =====================
    
    func numberOfRowsInTableView() -> Int {
        switch curFilterOption {
            case .None:
                return 0
            case .Artist:
                return musicRoot.numArtists
            case .Album:
                return musicRoot.numAlbums
            default:
                Helper.printError("System error, found an unknown enum value")
        }
        
        return 0
    }
    
    func tableView(rowViewForRow row: Int) -> NSTableRowView? {
        
        var type: MDSDataType!
        var dataId: MDSDataId!
        
        switch curFilterOption {
            case .Artist:
                type = .MDSArtistType
                dataId = musicRoot.getArtist(idx: row).id
            case .Album:
                type = .MDSAlbumType
                dataId = musicRoot.getAlbum(idx: row).id
            case .None:
                Helper.printError("Request for filter table row when filter option is None")
                return nil
            default:
                Helper.printError("Unkown filter option")
                return nil
        }
        
        var result = tableView.makeViewWithIdentifier(rowId, owner: self) as? MusicTableRowView
        
        if result == nil {
            result = MusicTableRowView(type: type, dataId: dataId)
        } else {
            result!.setId(type, dataId: dataId)
        }
        
        return result
        
    }
    
    func tableView(viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var rowView = tableView.rowViewAtRow(row, makeIfNecessary: false) as MusicTableRowView
        
        var text: String!
        switch curFilterOption {
        case .Artist:
            assert(rowView.type == MDSDataType.MDSArtistType)
            text = musicRoot.getArtist(artistId: rowView.dataId as MDSArtistId).name
        case .Album:
            assert(rowView.type == MDSDataType.MDSAlbumType)
            text = musicRoot.getAlbum(albumId: rowView.dataId as MDSAlbumId).title
        case .None:
            Helper.printError("Recieved request for a filter table cell view while filter option is none")
            return nil
        default:
            Helper.printError("Unknown enum value")
            return nil
        }
        
        var result = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView
        
        assert(result != nil)
        
        result!.textField?.stringValue = text
        
        return result
    }
    
    // ====================== User Action Response =====================
    
    func rowSelected() {
        println("Filter table view selected, row: \(tableView.selectedRow)")
    }
    
    func updateFilterOption(control: NSSegmentedControl) {
        let oldOption = curFilterOption
        
        switch control.selectedSegment {
            case FilterOption.None.rawValue:
                println("None selected")
                curFilterOption = .None
            case FilterOption.Artist.rawValue:
                println("Artist selected")
                curFilterOption = .Artist
            case FilterOption.Album.rawValue:
                println("Album selected")
                curFilterOption = .Album
            default:
                Helper.printError("Recieved message from unknown segment")
        }
        
        if curFilterOption != oldOption {
            tableView.reloadData()
        }
    }
}
