/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

protocol LogDelegate{
    func updateLog()
}

class Log{
    
    static var chunks = Array<LogChunk>()
    
    static var delegate : LogDelegate? = nil

    static var logFileUrl = Paths.logFile.toFileUrl()!

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
        Files.appendToFile(text: msg + "\n", url: logFileUrl)

    }

}
