//
//  NotificationsSequence.swift
//  NotificationsSequence
//
//  Created by yasser on 2021-07-16.
//

import Foundation

public class NotificationsSequence: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Notification
    private let dispatchQueue = DispatchQueue(label: "NotificationsSequence.queue")
    private var notifications = [Notification]()
    private var currContinuation: CheckedContinuation<Notification?, Never>?
    private var stop = false
    
    public init() {
        
    }
    public func next() async throws -> Notification? {
        await withCheckedContinuation({ continuation in
            dispatchQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }
                
                if self.currContinuation != nil {
                    // TODO: Error...
                    return
                }
                
                if self.stop {
                    continuation.resume(returning: nil)
                }
                
                if self.notifications.isEmpty {
                    // Wait for something to show up.
                    self.currContinuation = continuation
                    return
                }
                let notification = self.notifications.popLast()
                continuation.resume(returning: notification)
            }
        })
    }
    
    public func makeAsyncIterator() -> NotificationsSequence {
        return self
    }
    
    public func publish(notification: Notification) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.stop {
                return
            }
            if let continuation = self.currContinuation {
                continuation.resume(returning: notification)
                self.currContinuation = nil
            } else {
                self.notifications.append(notification)
            }
        }
    }
    
    public func stopPublishing() {
        dispatchQueue.async {
            self.stop = true
        }
    }
}
