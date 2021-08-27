//
//  ContentView.swift
//  GuiReddit
//
//  Created by yasser on 2021-07-23.
//

import SwiftUI

/// The main content view that kicks things off.
struct ContentView: View {
    @State var currScreen: CurrScreen? = nil
    @StateObject var viewModel = PostsViewModel()
    
    var body: some View {
        VStack {
            if currScreen == nil {
                Text("Waiting to init session...")
            } else if currScreen == .currScreenSearch {
                SubredditView(viewState: viewModel, subreddit: "")
            } else {
                Text("Some other screen")
            }
        }
        .onAppear(perform: {
            Task {
                await viewModel.initSession()
                currScreen = viewModel.currScreen
            }
        })
        .frame(minWidth: 200,
               idealWidth: 200,
               maxWidth: .infinity,
               minHeight: 200,
               idealHeight: 200,
               maxHeight: .infinity,
               alignment: .center)
    }
        
}


