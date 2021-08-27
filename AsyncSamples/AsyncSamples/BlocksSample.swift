//
//  BlocksSample.swift
//  AsyncSamples
//
//  Created by yasser on 2021-07-08.
//

import Foundation


// Fake a lot of work.
func doesALotOfWork(workUnit: Int) async {
    print("Doing work... \(workUnit)")
    sleep(10_000) // Blocks the current OS thread from continuing, not how you should sleep in async/await.
}

// Fire up a bunch of tasks and have them do some work (but not really).
func blocksSample() async {
    await withTaskGroup(of: Void.self, body: { group in
        for i in 1...10_000 {
            group.async {
                await doesALotOfWork(workUnit: i)
            }
        }
    })
}
