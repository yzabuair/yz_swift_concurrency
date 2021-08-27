//
//  ErrorInfo.swift
//  Shared
//
//  Created by yasser on 2021-07-10.
//

import Foundation

/// Information that helps us locate the error.
public struct ErrorInfo {
    public let description: String
    public let file: String
    public let line: Int
    
    public init(description: String,
                file: String,
                line: Int) {
        self.description = description
        self.file = file
        self.line = line
    }
}
