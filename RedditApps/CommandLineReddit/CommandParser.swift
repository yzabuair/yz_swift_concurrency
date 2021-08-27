//
//  CommandParser.swift
//  CommandLineReddit
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Shared


struct CommandParser {
    private let commandLine: String
    
    init(commandLine: String) {
        self.commandLine = commandLine
    }
    
    func parse() -> Result<Command, Errors> {
        var currCommand = String()
        var args: [String: String]? = [:]
        var currArg = String()
        var commandFound = false
        var firstArg = true
        var argName = false
        for currChar in self.commandLine {
            if !commandFound {
                if currChar == " " ||
                   currChar == "\n" {
                    commandFound = true
                    continue
                }
                currCommand.append(currChar)
            } else {
                // The first arg needs no name.
                if currChar == " " ||
                    currChar == "\n" {
                    print("currArg = \(currArg)")
                    args?["FirstArg"] = currArg
                    
                    currArg.removeAll()
                    firstArg = false
                    
                    continue
                }
                currArg.append(currChar)
            }
        }
        
        if currCommand.isEmpty {
            // TODO: Error
        }
        
        if !currArg.isEmpty {
            args?["FirstArg"] = currArg
        }
        
        
        if args?.isEmpty == true {
            args = nil
        }
        
        return .success(Command(commandName: currCommand, commandArgs: args) )
    }
    
}
