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
    
    func tableView(rowViewForRow row: Int) -> FilterTableRowView? {
        
//        var type: MDSDataType!
//        var dataId: MDSDataId!
        
        var container: MDSSongContainer!
        
        switch curFilterOption {
            case .Artist:
//                type = .MDSArtistType
//                dataId = musicRoot.getArtist(idx: row).id
                container = musicRoot.getArtist(idx: row)
            case .Album:
//                type = .MDSAlbumType
//                dataId = musicRoot.getAlbum(idx: row).id
                container = musicRoot.getAlbum(idx: row)
            case .None:
                Helper.printError("Request for filter table row when filter option is None")
                return nil
            default:
                Helper.printError("Unkown filter option")
                return nil
        }
        
        var result = tableView.makeViewWithIdentifier(rowId, owner: self) as? FilterTableRowView
        
        if result == nil {
            result = FilterTableRowView(data: container)
        } else {
            result!.data = container
        }
        
        return result
        
    }
    
    func tableView(viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var rowView = tableView.rowViewAtRow(row, makeIfNecessary: false) as FilterTableRowView
        
        var text: String!
        switch rowView.data.type {
            case MDSDataType.MDSArtistType:
                text = (rowView.data as MDSArtist).name
            case MDSDataType.MDSAlbumType:
                text = (rowView.data as MDSAlbum).title
            default:
                Helper.printError("Filter table has row view with unsupported MDSDataType")
                return nil
        }
        
        var result = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView
        assert(result != nil)
        
        result!.textField?.stringValue = text
        
        return result
        
//        var text: String!
//        switch curFilterOption {
//        case .Artist:
//            text = rowView.data.
//        case .Album:
//            assert(rowView.type == MDSDataType.MDSAlbumType)
//            text = musicRoot.getAlbum(albumId: rowView.dataId as MDSAlbumId).title
//        case .None:
//            Helper.printError("Recieved request for a filter table cell view while filter option is none")
//            return nil
//        default:
//            Helper.printError("Unknown enum value")
//            return nil
//        }
//        
//        var result = tableView.makeViewWithIdentifier(cellId, owner: self) as? NSTableCellView
//        
//        assert(result != nil)
//        
//        result!.textField?.stringValue = text
//        
//        return result
    }
    
    // ====================== User Action Response =====================
    
    func getSelectedSongContainer() -> MDSSongContainer? {
        var selectedRow = tableView.rowViewAtRow(tableView.selectedRow, makeIfNecessary: false) as FilterTableRowView
        
        return selectedRow.data
        
//        var container: MDSSongContainer!
//        switch curFilterOption {
//        case .Artist:
//            assert(selectedRow.type == .MDSArtistType)
//            container = musicRoot.getArtist(artistId: selectedRow.dataId as MDSArtistId)
//        case .Album:
//            assert(selectedRow.type == .MDSAlbumType)
//            container = musicRoot.getAlbum(albumId: selectedRow.dataId as MDSAlbumId)
//        case .None:
//            Helper.printError("Request for selected filter row when filter option is None")
//            return nil
//        default:
//            Helper.printError("Unknown filter option")
//            return nil
//        }
//        
//        return container
    }
    
    // Returns true if none was selected, false otherwise
    func updateFilterOption(control: NSSegmentedControl) -> Bool {
        var noneSelected = false
        
        let oldOption = curFilterOption
        
        switch control.selectedSegment {
            case FilterOption.None.rawValue:
                println("None selected")
                curFilterOption = .None
                noneSelected = true
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
            if noneSelected {
                return true
            }
        }
        
        return false
    }
}
