//
//  Errors.swift
//  Errors
//
//  Created by yasser on 2021-08-02.
//

import Shared

/// Information conveyed for errors.
struct Errors: Error {
    enum ErrKind: String {
        case notLoggedOn
        case parseError
        case unknownSubreddit
        case httpError
        case jsonResponseError
        case caughtException
    }
    
    let errInfo: ErrorInfo
}
