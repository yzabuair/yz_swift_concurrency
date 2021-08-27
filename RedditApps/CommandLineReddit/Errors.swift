//
//  Errors.swift
//  CommandLineReddit
//
//  Created by yasser on 2021-07-10.
//

import Foundation
import Shared

enum Errors: Error {
    case UnknownCommand(ErrorInfo)
    case ParseError(ErrorInfo)
    case InvalidArgument(ErrorInfo)
    
}
