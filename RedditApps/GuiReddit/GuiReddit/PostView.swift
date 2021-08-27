//
//  PostView.swift
//  PostView
//
//  Created by yasser on 2021-08-18.
//

import SwiftUI
import Shared

struct PostView: View {
    @ObservedObject var viewState: PostsViewModel
    let subreddit: String
    let currPost: RedditPost
    
    var body: some View {
        VStack {
            Text(currPost.title)
            AsyncImage(url: URL(string: currPost.thumbNail?.thumbnailUrl ?? "") )
                .frame(width: CGFloat(currPost.thumbNail?.width ?? 0),
                       height: CGFloat(currPost.thumbNail?.height ?? 0),
                       alignment: .center)
                
            Text("author: " + currPost.author)
            NavigationLink("", destination: CommentsView(viewState: viewState, subreddit: subreddit, postId: currPost.postId) )
        }
        .onAppear(perform: {
            print("*** url = ", currPost.thumbNail?.thumbnailUrl ?? "")
        })
    }
    
}

