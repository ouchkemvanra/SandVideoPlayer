//
//  SandPlayerCacheConfiguration.swift
//  SandVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation

open class SandPlayerCacheConfiguration: NSObject {
    
    open var maxCacheAge: TimeInterval = 60 * 60 * 24 * 7 // 1 week
     
    /// The maximum size of the cache, in bytes.
    open var maxCacheSize: UInt = 0
}
