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
    
    
    // ====================== Controller =====================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTableId = filterTableView?.identifier
        selectTableId = selectTableView?.identifier
        
        fetchMusicDataFromXML()
    }
    
    
    
    // ====================== Delegate/DataSource =====================
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (tableView.identifier == "filterTable"
            ? numberOfRowsInFilterTableView()
            : numberOfRowsInSelectTableView())
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        assert(tableColumn != nil)
        
        return (tableView.identifier == "filterTable"
            ? filterTableView(tableView, viewForTableColumn: tableColumn!, row: row)
            : selectTableView(tableView, viewForTableColumn: tableColumn!, row: row))
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
        return 5
    }
    
    func selectTableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn, row: Int) -> NSView? {
        
        var result = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView
        
        assert(result != nil)
        
        result!.textField?.stringValue = "select table item"
        
        return result
    }
    
}