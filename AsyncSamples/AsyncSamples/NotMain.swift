//
//  NotMain.swift
//  AsyncSamples
//
//  Created by yasser on 2021-07-07.
//

import Foundation


/// In the current beta you have to have a top-level @main, main.swift does not seem to work.
@main
struct App {
    static func main() async {
        //await asyncSample()
        //await countSample()
        //await blocksSample()
        //await callbackSample()
        await asyncSequenceSample()
    }
}
