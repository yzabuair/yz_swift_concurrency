//
//  CountSample.swift
//  AsyncSamples
//
//  Created by yasser on 2021-07-07.
//

import Dispatch
import Foundation

// The global value we increment.
var value: Int = 0

// An async version of increment.
func increment() async {
    value += 1
}

// The actor that works serially.
actor Counter {
    var actorValue: Int = 0
    
    func increment() async {
        actorValue += 1
    }
    
}

// Uses GCD to fire up many jobs and count up.
var numJobs = 0
func gcdParallelCount() {
    
    // Use a parallel dispatch queue and count up, and a serial queue to make sure we submit as many jobs as we expect.
    value = 0
    let serialQueue = DispatchQueue(label: "serialQueue")
    let parallelQueue = DispatchQueue(label: "parallelQueue", attributes: .concurrent)
    for _ in 1...10_000 {
        parallelQueue.async {
            value += 1
            // Serial queue makes sure we submitted the number of jobs we said we would.
            serialQueue.sync {
                numJobs += 1
            }
        }
    }
    
    // Give some time to run.
    sleep(5)
    
    // Make sure we ran 10,000 times.
    assert(numJobs == 10_000)
    
    print("value 1 = \(value)")
}

// Uses async/await and Tasks to fire up many tasks and count up.
func asyncCount() async {
    
    // Fire up many tasks and count up using async/await.
    value = 0
    await withTaskGroup(of: Void.self, body: { group in
        for _ in 1...10_000 {
            group.async {
                await increment()
            }
        }
    })
    
    print("value 2 = \(value)")
}

// Uses an actor to count up.
func actorCount() async {
    
    // Fire up many tasks and count up using actor
    let counter = Counter()
    await withTaskGroup(of: Void.self, body: { group in
        for _ in 1...10_000 {
            group.async {
                await counter.increment()
            }
        }
    })
    
    print("value 3 = \(await counter.actorValue)")
}


func countSample() async {
    gcdParallelCount()
    await asyncCount()
    await actorCount()
}
