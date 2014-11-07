//
//  MainViewController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/30/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    // ====================== View Outlets =====================
    @IBOutlet
    var filterTableView: NSTableView?
    
    @IBOutlet
    var selectTableView: NSTableView?
    
    
    
    // ====================== Globals =====================
    // Contains all music data once initialized
    var musicRoot: MDSMusic!
    
    var selectTable: SelectTable!
    var filterTable: FilterTable!
    
    // ====================== Controller =====================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicRoot = fetchMusicDataFromXML()
        assert(musicRoot != nil)
        
        selectTable = SelectTable(tableView: selectTableView!, musicRoot: musicRoot)
        filterTable = FilterTable(tableView: filterTableView!, musicRoot: musicRoot)
    }
    
    
    
    // ====================== Delegate/DataSource =====================
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView.identifier {
            case filterTable.tableId:
                return filterTable.numberOfRowsInTableView()
            case selectTable.tableId:
                return selectTable.numberOfRowsInTableView()
            default:
                Helper.printError("Delegate received request from unknown tableView")
        }
        
        return 0
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        
        switch tableView.identifier {
        case filterTable.tableId:
            return filterTable.tableView(rowViewForRow: row)
        case selectTable.tableId:
            return selectTable.tableView(rowViewForRow: row)
        default:
            Helper.printError("Recieved message from unknwon tableView")
        }
        
        return nil
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        assert(tableColumn != nil)
        
        switch tableView.identifier {
        case filterTable.tableId:
            return filterTable.tableView(viewForTableColumn: tableColumn!, row: row)
        case selectTable.tableId:
            return selectTable.tableView(viewForTableColumn: tableColumn!, row: row)
        default:
            Helper.printError("Delegate received request from unknown tableView")
        }
        
        return nil
    }
    
    // ====================== Segmented Control =====================
    
    @IBAction
    func segmentedControlClicked(sender: AnyObject) {
        filterTable.updateFilterOption(sender as NSSegmentedControl)
    }
    
    
    // ====================== Row Selection =====================
    @IBAction
    func rowSelected(sender: AnyObject) {
        let tableView = sender as NSTableView
        
        switch tableView.identifier {
        case filterTable.tableId:
            filterTable.rowSelected()
        case selectTable.tableId:
            selectTable.rowSelected()
        default:
            Helper.printError("Recieved message from unknown table view")
        }
    }
}