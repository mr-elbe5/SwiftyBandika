//
//  LogChunk.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 09.02.21.
//

import Foundation

class LogChunk{
    
    let string : String
    let level : LogLevel
    var displayed : Bool = false
    
    init(_ string: String,level: LogLevel){
        self.string = string
        self.level = level
    }
    
}
