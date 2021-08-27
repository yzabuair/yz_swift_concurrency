//
//  RedditData.swift
//  Shared
//
//  Created by yasser on 2021-07-13.
//

import Foundation


public struct Thumbnail {
    public let thumbnailUrl: String
    public let postId: String
    public let width: Int
    public let height: Int
    public var imageData: Data? = nil
    
    public init(thumbnailUrl: String,
                postId: String,
                width: Int,
                height: Int,
                imageData: Data? = nil) {
        self.thumbnailUrl = thumbnailUrl
        self.postId = postId
        self.width = width
        self.height = height
        self.imageData = imageData
    }
    
}

public struct RedditPost: Identifiable {
    public let id = UUID()
    public let title: String
    public let author: String
    public let postId: String
    public let upVotes: Int
    public let downVotes: Int
    public var thumbNail: Thumbnail? = nil
    
    public init(title: String,
                author: String,
                postId: String,
                upVotes: Int,
                downVotes: Int) {
        self.title = title
        self.author = author
        self.postId = postId
        self.upVotes = upVotes
        self.downVotes = downVotes
    }
}

public struct RedditComment: Identifiable {
    public let id = UUID()
    public let body: String
    public let author: String
    public let commentId: String
    public let parentId: String
    public var childComments: [RedditComment]? = nil
    
    public init(body: String,
                author: String,
                commentId: String,
                parentId: String,
                childComments: [RedditComment]? = nil) {
        self.body = body
        self.author = author
        self.commentId = commentId
        self.parentId = parentId
        self.childComments = childComments
    }
}

