//
//  PreferenceWindowController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/28/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa

class PreferenceWindowController: NSWindowController {
    
    // Keys for dictionaries and ids for toolbar items
    let parentId: String = "parent"
    let generalId: String = "general"
    let otherId: String = "other"
    
    // Top level view that will hold the views we wish to swap in and out
    var parentBox: NSBox? = nil

    // Dictionary of all views (parent and potential swapped subviews)
    var VCDict = [String : NSViewController]()
    
    // Currently visible subview and constraints
    var currentVC: NSViewController? = nil
    var currentConstraints: [AnyObject]? = nil
    
    
    // Toolbar item selection
    @IBAction
    func toolbarClicked(sender: AnyObject) {
        
        swapViews((sender as NSToolbarItem).itemIdentifier)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Require a single NSBox to be in contentView immediately after load
        assert(self.window?.contentView?.subviews.count == 1)
        
        // Store reference to NSBox in var parentBox
        parentBox = self.window?.contentView?.subviews[0] as? NSBox
        assert(parentBox != nil)
        
        // Initialize views with constraints and push into dictionary
        initializeVCs()
        
        // Setup general as initial view to show
        var initialVC: NSViewController = VCDict[generalId]!
        parentBox!.addSubview(initialVC.view)
        currentVC = initialVC
        updateConstraints(currentVC!)
    }
    
    func initializeVCs() {
        var generalVC = PreferenceGeneralViewController(nibName: "PreferenceGeneralViewController", bundle: nil)
        assert(generalVC != nil)
        var otherVC = PreferenceOtherViewController(nibName: "PreferenceOtherViewController", bundle: nil)
        assert(otherVC != nil)
        
        VCDict[generalId] = generalVC!
        VCDict[otherId] = otherVC!
        
        for (_, vc) in VCDict {
            vc.view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func swapViews(viewId: String) {
        assert(currentVC != nil)
        
        if let newVC = VCDict[viewId] {
            parentBox!.replaceSubview(currentVC!.view, with: newVC.view)
            currentVC = newVC
            updateConstraints(currentVC!)
        } else {
            println("Could not swap to unknown view controller with id: \(viewId)")
        }
    }
    
    func updateConstraints(vc: NSViewController) {
        
//        println("thisView: \(view)")
//        println("parentView: \(view.superview)")
        
        // Remove any old constraints
        if currentConstraints != nil {
            parentBox!.removeConstraints(currentConstraints!)
        }
        
        // Create new constraints
        var horizontalFormatString: String = "H:|[thisView]|"
        var verticalFormatString: String = "V:|[thisView]|"
        
        var layoutConstraints: [AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat(
            horizontalFormatString,
            options:  NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["thisView" : vc.view])
        layoutConstraints += NSLayoutConstraint.constraintsWithVisualFormat(
            verticalFormatString,
            options:  NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["thisView" : vc.view])
        
        // Add new constraints
        parentBox!.addConstraints(layoutConstraints)
        currentConstraints = layoutConstraints
    }
}
