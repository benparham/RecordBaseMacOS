//
//  SelectTableRowView.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/9/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class SelectTableRowView: NSTableRowView {

    var data: MDSSong!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    init(data: MDSSong) {
        self.data = data
        super.init(frame: CGRectMake(0, 0, 0, 0))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
}