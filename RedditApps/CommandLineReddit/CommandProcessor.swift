//
//  CommandProcessor.swift
//  CommandLineReddit
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Shared


actor CommandProcessor {
    private let engine: Engine
    private var sessionId: Int!
    private var notificationTask: Task<Void, Never>? = nil
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    deinit {
        if let task = notificationTask {
            self.engine.notifications.stopPublishing()
            task.cancel()
        }
    }
    
    func processCommand(command: Command) async -> Result<Void, Errors> {
        if command.commandName == "help" {
            processHelp(command: command)
        } else if command.commandName == "initsession" {
            await initSession(command: command)
        } else if command.commandName == "subreddit" {
            await processSubreddit(command: command)
        } else {
            return .failure(Errors.UnknownCommand(ErrorInfo(description: "Unknown command \(command.commandName)",
                                                            file: #file,
                                                            line: #line) ) )
        }
        
        return .success(() )
    }
    
    func processNotification(notification: Shared.Notification) async {
        if case let Shared.Notification.engineHeartbeat(when) = notification {
            print("Heartbeat received at: \(when)")
        }
    }
    
    
    private func processHelp(command: Command) {
        print("Commands: ")
        print("      help -- This screen.")
        print(" initsession -- Initializes the session.")
        print(" subreddit: subreddit SUBRREDDIT -- The subreddit to query and show posts from.")
        print(" post: post POSTID -- Views the comments for a post.")
    }
    
    private func initSession(command: Command) async {
        let replyAction = await engine.sendAction(action: Action.initSession(userId: "testId") )
        switch replyAction {
        case .errorReply(let errorScreen):
            print("\(errorScreen.title): ")
            print(" description: \(errorScreen.description)")
            print(" file: \(errorScreen.file)")
            print(" line: \(errorScreen.line)")
        case .initSessionReply(let sessionId, _):
            self.sessionId = sessionId
            await self.engine.run()
            notificationTask = Task { () async -> Void in
                do {
                    for try await currNotificaiton in self.engine.notifications {
                        await processNotification(notification: currNotificaiton)
                    }
                } catch {
                    print("Notification error: ", error)
                }
            }
        default:
            print("Unexpected reply")
        }
    }
    
    private func processSubreddit(command: Command) async {
        let actionReply = await engine.sendAction(action: Action.querySubReddit(sessionId: self.sessionId, subreddit: command.commandArgs?["FirstArg"] ?? "") )
        
        switch actionReply {
        case .errorReply(let errorScreen):
            print("\(errorScreen.title): ")
            print(" description: \(errorScreen.description)")
            print(" file: \(errorScreen.file)")
            print(" line: \(errorScreen.line)")
        case .querySubredditReply(let subredditScreen):
            if let posts = subredditScreen.posts {
                for currPost in posts {
                    print("\(currPost.title)")
                    print("author: \(currPost.author)")
                    print("---")
                }
            }
        default:
            print("Unexpected reply")
        }
    }
    
    
}
