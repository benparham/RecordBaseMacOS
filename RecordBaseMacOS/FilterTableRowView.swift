//
//  FilterTableRowView.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/8/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class FilterTableRowView: NSTableRowView {

    var data: MDSSongContainer!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    init(data: MDSSongContainer) {
        self.data = data
        super.init(frame: CGRectMake(0, 0, 0, 0))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
}
