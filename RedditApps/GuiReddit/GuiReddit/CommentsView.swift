//
//  CommentsView.swift
//  CommentsView
//
//  Created by yasser on 2021-08-07.
//

import SwiftUI




struct CommentsView: View {
    @State var currScreen: CurrScreen? = nil
    @State var alertMessage: String = ""
    @State var showingAlert = false
    @ObservedObject var viewState: PostsViewModel
    let subreddit: String
    let postId: String
    
    var body: some View {
        VStack {
            if currScreen == nil || currScreen == .currScreenBlank {
                Text("Loading comments...")
            } else {
                if viewState.errorScreen != nil {
                    Text("Whoops... error...")
                } else if viewState.commentsScreen?.comments == nil {
                    Text("No Comments")
                } else {
                    if viewState.commentsScreen!.comments!.isEmpty {
                        Text("No Comments")
                    } else {
                        List(viewState.commentsScreen!.comments!,
                             children: \.childComments) { currComment in
                            Text("\(currComment.body)\nauthor: \(currComment.author)")
                        }
                        .listStyle(. bordered(alternatesRowBackgrounds: true))
                    }
                }
            }
        }
        .onAppear(perform: {
            Task {
                await viewState.queryComments(subreddit: subreddit, postId: postId)
                currScreen = viewState.currSubScreen
                if self.viewState.currSubScreen == .currScreenError {
                    showingAlert = true
                    alertMessage = "\(self.viewState.errorScreen!.description)\n"
                    alertMessage += "[\(self.viewState.errorScreen!.file) : \(self.viewState.errorScreen!.line)]"
                }
            }
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(viewState.errorScreen?.title ?? ""),
                  message: Text(alertMessage) )
        }
    }

}

