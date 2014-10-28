//
//  ItemTableViewController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/28/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class ItemTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet
    var tableView: NSTableView!
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.items = [
            Item(Category: "Animal", name: "Dog"),
            Item(Category: "Animal", name: "Cat"),
            Item(Category: "Animal", name: "Fish"),
            Item(Category: "Name", name: "Matt"),
            Item(Category: "Name", name: "John"),
            Item(Category: "Name", name: "Frank")
        ]
        
        self.tableView.reloadData();
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return self.items[row].name
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Require the table column option to be set
        if tableColumn == nil {
            println("nil table column")
            return nil
        }
        
        var result = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? NSTableCellView
        if result == nil {
            println("Couldn't find NSTableCellView")
            return nil
        }
        
        result!.textField?.stringValue = self.items[row].name
        
        return result
    }
    
//    func tableViewSelectionDidChange(notification: NSNotification) {
//        
//    }
    
}