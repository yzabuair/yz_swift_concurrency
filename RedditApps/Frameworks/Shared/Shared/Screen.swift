//
//  Screen.swift
//  Shared
//
//  Created by yasser on 2021-07-13.
//

import Foundation
      
public struct SubredditScreen {
    public let title: String
    public let searchButtonTitle: String
    public let posts: [RedditPost]?
    
    public init(title: String,
                searchButtonTitle: String,
                posts: [RedditPost]?) {
        self.title = title
        self.searchButtonTitle = searchButtonTitle
        self.posts = posts
    }
}

public struct CommentsScreen {
    public let title: String
    public let comments: [RedditComment]?
    
    public init(title: String,
                comments: [RedditComment]?) {
        self.title = title
        self.comments = comments
    }
}

public struct ErrorScreen {
    public init(title: String,
                description: String,
                file: String,
                line: Int) {
        self.title = title
        self.description = description
        self.file = file
        self.line = line
    }
    
    public let title: String
    public let description: String
    public let file: String
    public let line: Int
}
