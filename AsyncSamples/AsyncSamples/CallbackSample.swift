//
//  CallbackSample.swift
//  AsyncSamples
//
//  Created by yasser on 2021-07-09.
//

import Dispatch
import Foundation

/// Simple class that can execute task at a later time.
class TimerClass {
    func scheduleSomeWorkAfterSomeSeconds(waitSecs: Int) async {
        await withCheckedContinuation({ continuation in
            scheduleSomeWorkAfterSomeSecondsCallback(waitSecs: waitSecs, workToDo: {
                continuation.resume()
            })
        })
    }
    
    func scheduleSomeWorkAfterSomeSecondsCallback(waitSecs: Int,
                                                  workToDo: @escaping () -> Void) {
        let queue = DispatchQueue.global()
        let nowTime = DispatchTime.now()
        let execTime = nowTime.advanced(by: DispatchTimeInterval.seconds(waitSecs) )
        
        print("Scheduling some work: \(Date() )")
        queue.asyncAfter(deadline: execTime, execute: {
            workToDo()
        })
    }
}

// Uses a callback to do some work.
func doCallback() {
    let myTimer = TimerClass()
    myTimer.scheduleSomeWorkAfterSomeSecondsCallback(waitSecs: 2, workToDo: {
        print("I did some work in a callback: \(Date() )")
    })
    
    // Give some time for the callback to run.
    sleep(3)
}

// Uses async/await to wait and then run.
func doAsync() async {
    let myTimer = TimerClass()
    await myTimer.scheduleSomeWorkAfterSomeSeconds(waitSecs: 2)
    print("I did some work in an async function and now I am back baby: \(Date() )")
}

func callbackSample() async {
    doCallback()
    await doAsync()
}


