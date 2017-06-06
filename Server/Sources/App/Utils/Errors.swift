//
//  File.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//

import Foundation
import Debugging

public enum AccountError: Error {
    case taken
    case unspecified()
}



extension AccountError: Debuggable {
    public var reason: String {
        let reason: String
        
        switch self {
        case .taken:
            reason = "The account is already registered."
        case .unspecified(let error):
            reason = "\(error)"
        }
        
        return "Authentication error: \(reason)"
    }
    
    public var identifier: String {
        switch self {
        case .taken:
            return "The account is already registered."
        case .unspecified(let error):
            return "unspecified (\(error))"
        }
    }
    
    public var suggestedFixes: [String] {
        return []
    }
    
    public var possibleCauses: [String] {
        return []
    }
}
