//
//  Engine.swift
//  Shared
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Dispatch


/// An Engine is something written in some language that lets us talk to reddit.
public protocol Engine {
    func run() async
    
    func stop() async
    
    func sendAction(action: Action) async -> ActionReply
    
    var notifications: NotificationsSequence {
        get
    }
    
}
