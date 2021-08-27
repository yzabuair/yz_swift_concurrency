//
//  AppMain.swift
//  AppMain
//
//  Created by yasser on 2021-07-17.
//

import Foundation
import Shared


let notifications = NotificationsSequence()

@main
struct AppMain {
    static func main() async {
        let myTask = Task {
            var i = 1
            for try await notification in notifications {
                print("Received notification: \(i)")
                i += 1
            }
        }
        
        let myTask2 = Task {
            for _ in 1...10 {
                notifications.publish(notification: Notification.emptyNotification)
            }
        }
        
        await myTask2
        
        
        await myTask

        
        while true {
            RunLoop.main.run()
        }
    }
}
