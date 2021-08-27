//
//  Notification.swift
//  Shared
//
//  Created by yasser on 2021-07-13.
//

import Foundation

public enum Notification {
    case emptyNotification
    case engineHeartbeat(when: Date)
    case errorNotification(errorScreen: ErrorScreen)
}
