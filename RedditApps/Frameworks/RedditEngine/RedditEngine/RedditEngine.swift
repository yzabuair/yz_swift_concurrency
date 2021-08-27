//
//  RedditEngine.swift
//  RedditEngine
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Shared

/// The engine lets us talk to reddit via sessions.  You must initialize a session before doing anything else.
actor RedditEngine: Engine  {
    private var sessions = [(Int, SessionController)]()
    private var sessionId = 0
    private var notificationTask: Task<Void, Never>? = nil
    
    public let notifications = NotificationsSequence()
    
    init() {
        
    }
    
    deinit {
        notifications.stopPublishing()
        if let task = notificationTask {
            task.cancel()
        }
    }
    
    func run() async {
        notificationTask = Task {
            while true {
                if Task.isCancelled {
                    break
                }
                await Task.sleep(5_000_000_000)
                notifications.publish(notification: Notification.engineHeartbeat(when: Date() ) )
            }
        }
    }
    
    func stop() async {

    }
    
    func sendAction(action: Action) async -> ActionReply {
        switch action {
        case .initSession(_):
            print("creating new session...")
            let newSession  = SessionController()
            sessionId += 1
            sessions.append((sessionId, newSession))
            do {
                try await newSession.logonToReddit()
            } catch let err as Errors {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: err.errInfo.description,
                                                                       file: err.errInfo.file,
                                                                       line: err.errInfo.line) )
            } catch {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: "\(error)",
                                                                       file: #file,
                                                                       line: #line) )
            }
            
            return ActionReply.initSessionReply(sessionId: sessionId, searchScreen: SubredditScreen(title: "Title", searchButtonTitle: "SearchButton", posts: nil) )
        case .querySubReddit(let sessionId, let subreddit):
            var sessionController: SessionController?
            for (currId, session) in sessions {
                if currId == sessionId {
                    sessionController = session
                    break
                }
            }
            
            if sessionController == nil {
                return  ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error", description: "Unknown session", file: #file, line: #line) )
            }
            
            do {
                let posts = try await sessionController!.querySubreddit(subreddit: subreddit)
                return ActionReply.querySubredditReply(subredditScreen: SubredditScreen(title: "Title",
                                                                                        searchButtonTitle: "search",
                                                                                        posts: posts) )
                    
                
            } catch let err as Errors {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: err.errInfo.description,
                                                                       file: err.errInfo.file,
                                                                       line: err.errInfo.line) )
            } catch {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: "\(error)",
                                                                       file: #file,
                                                                       line: #line) )
            }
        
        case .queryComments(let sessionId, let subreddit, let postId):
            var sessionController: SessionController?
            for (currId, session) in sessions {
                if currId == sessionId {
                    sessionController = session
                    break
                }
            }
            
            if sessionController == nil {
                return  ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error", description: "Unknown session", file: #file, line: #line) )
            }
            
            do {
                let comments = try await sessionController!.queryPostComments(subreddit: subreddit, postId: postId)
                return ActionReply.queryCommentsReply(commentsScreen: CommentsScreen(title: "Comments", comments: comments) )
                
            } catch let err as Errors {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: err.errInfo.description,
                                                                       file: err.errInfo.file,
                                                                       line: err.errInfo.line) )
            } catch {
                return ActionReply.errorReply(errorScreen: ErrorScreen(title: "Error",
                                                                       description: "\(error)",
                                                                       file: #file,
                                                                       line: #line) )
            }
        }
    }

}

public func createEngine() -> Engine {
    return RedditEngine()
}


