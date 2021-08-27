//
//  Command.swift
//  CommandLineReddit
//
//  Created by yasser on 2021-07-10.
//

import Foundation


struct Command: CustomStringConvertible {
    let commandName: String
    let commandArgs: [String: String]?
    
    var description: String {
        var descr =  "commandName: \(commandName)\n"
        descr += "Args: \n"
        if let args = commandArgs {
            for currArg in args {
                descr += " \(currArg)"
            }
        }
        
        return descr
    }
}
