//
//  AppMain.swift
//  CommandLineReddit
//
//  Created by yasser on 2021-07-09.
//

import Foundation
import RedditEngine



@main
struct App {
    @MainActor
    static func main() async {
        print("CommandLineReddit, v0.00.01")
        let engine = createEngine()
        let processor = CommandProcessor(engine: engine)
        while true {
            print("Command ===> ", terminator: "")
            if let commandLine = readLine() {
                let parser = CommandParser(commandLine: commandLine)
                let result = parser.parse()
                switch result {
                case .success(let command):
                    if command.commandName == "quit" ||
                       command.commandName == "bye"  ||
                       command.commandName == "exit" {
                        print("*** End dBase III Session.")
                        return
                    }
                    
                    let result2 = await processor.processCommand(command: command)
                    switch result2 {
                    case .success:
                        print("*** Success")
                    case .failure(let error):
                        print("*** Error: \(error)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func processNotifications() async {
        
    }
}
