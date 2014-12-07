//
//  MainViewController.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/30/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Cocoa
import AVFoundation

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
    
    var audioPlayer: AVAudioPlayer?
    
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
    
    // ====================== Play/Pause Control =====================
    @IBAction
    func playPauseButtonClicked(sender: AnyObject) {
        println("Play/Pause was clicked!")
        
        if let song = selectTable.getSelectedSong() {
            audioPlayer = playSong(song)
        } else {
            println("No song selected for playback")
        }
    }
    
    // ====================== Segmented Control =====================
    
    @IBAction
    func segmentedControlClicked(sender: AnyObject) {
        if filterTable.updateFilterOption(sender as NSSegmentedControl) {
            selectTable.updateMusicRoot(musicRoot)
        }
    }
    
    
    // ====================== Row Selection =====================
    @IBAction
    func rowSelected(sender: AnyObject) {
        let tableView = sender as NSTableView
        
        switch tableView.identifier {
        case filterTable.tableId:
            var container: MDSSongContainer = filterTable.getSelectedSongContainer()
            selectTable.updateMusicRoot(container)
        case selectTable.tableId:
            if let song = selectTable.getSelectedSong() {
//                println("Song selected with file name: \(song.fileName)")
            }
        default:
            Helper.printError("Recieved message from unknown table view")
        }
    }
}