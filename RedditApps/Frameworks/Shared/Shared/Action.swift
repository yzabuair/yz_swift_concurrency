//
//  Action.swift
//  Shared
//
//  Created by yasser on 2021-07-13.
//

import Foundation

/// List of actions our engine can perform.
public enum Action {
    case initSession(userId: String)
    case querySubReddit(sessionId: Int, subreddit: String)
    case queryComments(sessionId: Int, subreddit: String, postId: String)
}

/// Replies we can get for the various actions.   Error can be returned for any request.
public enum ActionReply {
    case errorReply(errorScreen: ErrorScreen)
    case initSessionReply(sessionId: Int, searchScreen: SubredditScreen)
    case querySubredditReply(subredditScreen: SubredditScreen)
    case queryCommentsReply(commentsScreen: CommentsScreen)
}
