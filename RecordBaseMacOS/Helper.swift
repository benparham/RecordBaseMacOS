//
//  Helper.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Foundation

class Helper {
    
    class func printError(message: String) {
        println("ERROR: \(message)")
    }
    
    class func printError(message: String, error: NSError?) {
        if error == nil {
            return printError(message)
        }
        
        println("ERROR (\(error!.code)): \(message)")
        println("Description: \(error!.localizedDescription)")
        
        if let reason: String = error!.localizedFailureReason {
            println("Failure Reason: \(reason)")
        }
    }
}