//
//  Logger.swift
//  Log-Viewer
//
//  Created by Michael Rönnau on 09.12.20.
//

import Foundation

protocol LogDelegate{
    func updateLog()
}

class Log{
    
    static var chunks = Array<LogChunk>()
    
    static var delegate : LogDelegate? = nil
    
    static func info(_ string: String){
        log(string,level: .info)
    }
    
    static func warn(_ string: String){
        log(string,level: .warn)
    }
    
    static func error(_ string: String){
        log(string,level: .error)
    }

    static func error(error: Error){
        log(error.localizedDescription,level: .error)
    }
    
    private static func log(_ string: String, level : LogLevel){
        let msg = level.rawValue + Date().dateTimeString() + " " + string
        chunks.append(LogChunk(msg,level: level))
        delegate?.updateLog()
    }
}
