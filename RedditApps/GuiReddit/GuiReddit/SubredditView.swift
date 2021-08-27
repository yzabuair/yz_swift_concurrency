//
//  SearchView.swift
//  SearchView
//
//  Created by yasser on 2021-07-24.
//

import SwiftUI

/// The view used to look at subreddit posts.
struct SubredditView: View {
    @ObservedObject var viewState: PostsViewModel
    @State var subreddit: String
    @State var showingAlert = false
    @State var alertMessage: String = ""
    
    private let eventHandlerTask = Task {
        
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Subreddit: ", text: $subreddit)
                Button("Subreddit", action: {
                    Task {
                        await self.viewState.querySubreddit(subreddit: self.subreddit)
                        if self.viewState.currScreen == .currScreenError {
                            showingAlert = true
                            alertMessage = "\(self.viewState.errorScreen!.description)\n"
                            alertMessage += "[\(self.viewState.errorScreen!.file) : \(self.viewState.errorScreen!.line)]"
                        }
                    }
                } )
            }
            
            NavigationView {
                if viewState.searchScreen == nil || viewState.searchScreen?.posts == nil || viewState.currScreen == .currScreenError {
                    Text("No Posts")
                } else {
                    if viewState.searchScreen!.posts!.isEmpty {
                        Text("No Posts")
                    } else {
                        List {
                            ForEach(viewState.searchScreen!.posts!) { currPost in
                                PostView(viewState: viewState, subreddit: subreddit, currPost: currPost)
                            }
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                    }
                }
            }
            
            Text("Engine Heartbeat: " + viewState.heartbeat)
        }
        .onAppear(perform: {
        })
        .onDisappear(perform: {
            eventHandlerTask.cancel()
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(viewState.errorScreen?.title ?? ""),
                  message: Text(alertMessage) )
        }
    }
}

