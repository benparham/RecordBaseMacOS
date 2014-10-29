//
//  PreferenceWindowController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/28/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class PreferenceWindowController: NSWindowController {
    
    // Top level view that will hold the views we wish to swap in and out
    var parentBox: NSBox? = nil
    
    // Controller of the currently visible view
    var currentVC: NSViewController? = nil
    
    // Controllers for all views possible to swap in
    var generalVC: PreferenceGeneralViewController? = nil
    var otherVC: PreferenceOtherViewController? = nil
    
    // Toolbar item selection
    @IBAction
    func toolbarClicked(sender: AnyObject) {
        switch (sender as NSToolbarItem).itemIdentifier {
        case "general":
            // Should have been instantiated in windowDidLoad()
            swapViews(generalVC!)
        case "other":
            if otherVC == nil {
                otherVC = PreferenceOtherViewController(nibName: "PreferenceOtherViewController", bundle: nil)
                assert(otherVC != nil)
            }
            swapViews(otherVC!)
        default:
            println("Error, unaccounted for toolbar item")
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Require a single NSBox to be in contentView immediately after load
        assert(self.window?.contentView?.subviews.count == 1)
        
        parentBox = self.window?.contentView?.subviews[0] as? NSBox
        assert(parentBox != nil)
        
        generalVC = PreferenceGeneralViewController(nibName: "PreferenceGeneralViewController", bundle: nil)
        assert(generalVC != nil)
        
        swapViews(generalVC!)
    }
    
    func swapViews(newVC: NSViewController) {
        // Remove the old subview
        if currentVC != nil {
            currentVC?.view.removeFromSuperview()
        }
        
        // Append new subview
        currentVC = newVC
        parentBox!.addSubview(currentVC!.view)
    }
}
