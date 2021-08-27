//
//  ViewModel.swift
//  ViewModel
//
//  Created by yasser on 2021-07-23.
//

import Dispatch
import RedditEngine
import Shared
import SwiftUI

/// What screen are we currently showing.
enum CurrScreen: String {
    case currScreenBlank
    case currScreenError
    case currScreenSearch
    case currScreenComments
}

/// The model we use to interact between the engine and the viewa.
@MainActor
class PostsViewModel: ObservableObject {
    var currScreen: CurrScreen = .currScreenBlank
    var currSubScreen: CurrScreen = .currScreenBlank
    
    @Published var errorScreen: ErrorScreen? = nil
    @Published var searchScreen: SubredditScreen? = nil
    @Published var commentsScreen: CommentsScreen? = nil
    @Published var showAlert = false
    @Published var heartbeat: String = "None"
    
    private var sessionId = 0
    private let engine = RedditEngine.createEngine()
    private var notificationTask: Task<Void, Never>? = nil
    
    deinit {
        engine.notifications.stopPublishing()
        
        if let task = notificationTask {
            task.cancel()
        }
    }
    
    func initSession() async {
        await engine.run()
        
        let actionReply = await engine.sendAction(action: Action.initSession(userId: "does_not_matter") )
        switch actionReply {
            case .initSessionReply(let sessionId, let searchScreen):
                self.sessionId = sessionId
                self.searchScreen = searchScreen
                self.currScreen = .currScreenSearch
            
                // Once the engine is initialized start reading notifications.
                notificationTask = Task {
                    do {
                        for try await currNotification in engine.notifications {
                            self.processHeartBeat(notification: currNotification)
                        }
                    } catch {
                        print("*** We got an error: \(error)")
                    }
                }
            case .errorReply(let errorScreen):
                self.errorScreen = errorScreen
                self.currScreen = .currScreenError
            default:
                print("*** Hey, wha happen...")
        }
    }
    
    func querySubreddit(subreddit: String) async {
        errorScreen = nil
        searchScreen = nil
        commentsScreen = nil
        let actionReply = await engine.sendAction(action: Action.querySubReddit(sessionId: sessionId, subreddit: subreddit) )
        switch actionReply {
        case .querySubredditReply(let subredditScreen):
            self.searchScreen = subredditScreen
            self.currScreen = .currScreenSearch
        case .errorReply(let errorScreen):
            self.errorScreen = errorScreen
            self.currScreen = .currScreenError
        default:
            print("*** Hey, wha happen...")
        }
    }
    
    func queryComments(subreddit: String, postId: String) async {
        errorScreen = nil
        commentsScreen = nil
        let actionReply = await engine.sendAction(action: Action.queryComments(sessionId: sessionId, subreddit: subreddit, postId: postId) )
        switch actionReply {
        case .queryCommentsReply(let commentsScreen):
            self.commentsScreen = commentsScreen
            self.currSubScreen = .currScreenComments
            
            print("*** Dump comments again")
            dumpComments(self.commentsScreen!.comments!, indent: 0)
        case .errorReply(let errorScreen):
            self.errorScreen = errorScreen
            self.currSubScreen = .currScreenError
        default:
            print("*** Hey, wha happen...")
        }
    }
    
    private func processHeartBeat(notification: Shared.Notification) {
        if case let Shared.Notification.engineHeartbeat(when) = notification {
            heartbeat = "Received at: \(when)"
        }
    }
    
    private func dumpComments(_ comments: [RedditComment], indent: Int) {
        for currComment in comments {
            
            var indentStr = ""
            for _ in 0...indent {
                indentStr += " "
            }
            print("\(indentStr) \(currComment.body)")
            
            if currComment.childComments != nil {
                dumpComments(currComment.childComments!, indent: indent + 2)
            }
        }
    }
    

    
}
