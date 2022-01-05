//
//  SandPlayerCacheAction.swift
//  SandVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation

public enum SandPlayerCacheActionType: Int {
    case local
    case remote
}

public struct SandPlayerCacheAction: Hashable, CustomStringConvertible {
    public var type: SandPlayerCacheActionType
    public var range: NSRange
    
    public var description: String {
        return "type: \(type)  range:\(range)"
    }
    
    public var hashValue: Int {
        return String(format: "%@%@", NSStringFromRange(range), String(describing: type)).hashValue
    }
    
    public static func ==(lhs: SandPlayerCacheAction, rhs: SandPlayerCacheAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    init(type: SandPlayerCacheActionType, range: NSRange) {
        self.type = type
        self.range = range
    }
    
}
