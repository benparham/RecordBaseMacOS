//
//  MusicTableRowView.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/7/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class MusicTableRowView: NSTableRowView {

    var type: MDSDataType!
    var dataId: MDSDataId!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    init(type: MDSDataType, dataId: MDSDataId) {
        self.type = type
        self.dataId = dataId
        super.init(frame: CGRectMake(0, 0, 200, 20))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    
    func setId(type: MDSDataType, dataId: MDSDataId) {
        self.type = type
        self.dataId = dataId
    }
}
