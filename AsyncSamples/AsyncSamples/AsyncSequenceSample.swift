//
//  AsyncSequenceSample.swift
//  AsyncSamples
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Dispatch


struct AsyncCounter: AsyncSequence {
    typealias Element = Int
    let howHigh: Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        let howHigh: Int
        var current = 0
        
        mutating func next() async -> Int? {
            guard current <= howHigh else {
                return nil
            }
            
            let result = current
            current += 1
            
            // Sleep a bit (random amount) to simulate doing some work.
            await Task.sleep(UInt64.random(in: 100_000_000...500_000_000) )
            
            
            return result
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
   }
}
    
/// Only get the even numbers.
func evens() async {
    for await i in AsyncCounter(howHigh: 100).filter({ currNum in
        if (currNum % 2 == 0) {
            return true
        }
        return false
    }) {
        print("\(i)")
    }
}

func asyncSequenceSample() async {
    await evens()
}




