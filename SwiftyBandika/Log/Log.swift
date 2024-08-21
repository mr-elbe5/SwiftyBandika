/*
 SwiftyLog - A Swift Logger
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public class Log{

    public static var logLevel : LogLevel = .disabled

    private static var logFileUrl : URL? = nil
    private static var useQueue = false
    private static var queue = Array<LogChunk>()
    private static var useConsoleOutput = false
    private static var delegate : LogDelegate? = nil

    private static var dateTimeFormatter = getDateTimeFormatter()
    
    private static let semaphore = DispatchSemaphore(value: 1)
    
    private static func lock(){
        semaphore.wait()
    }

    private static func unlock(){
        semaphore.signal()
    }

    /**
     initialize logging on a certain level - default is .disabled
     - Parameter level: log level from .debug to .error or .disabled
     */
    public static func useLog(level: LogLevel) {
        Log.logLevel = level
    }

    /**
     initialize logging by file. The file will be created if it does not exist
     - Parameter url: url of the log file
     - Returns: true if file exists or could be created
     */
    public static func useLogFile(url: URL) -> Bool{
        if FileManager.default.fileExists(atPath: url.path){
            Log.logFileUrl = url
        }
        else if FileManager.default.createFile(atPath: url.path, contents: nil){
            Log.logFileUrl = url
        }
        print("using log file \(Log.logFileUrl?.path ?? "")")
        return Log.logFileUrl != nil
    }

    public static func useConsoleOutput(flag: Bool){
        useConsoleOutput = flag
    }

    /**
     May be called once without delegate (if not yet ready) to start the queue
     Call later with delegate to receive callbacks
     The delegate is responsible for retrieving chunks from the queue - otherwise it will pile up
     - Parameter delegate: LogDelegate or nil
     - Parameter useQueue: use queue (needed for delegate) - false clears the queue
     */
    public static func useDelegate(_ delegate: LogDelegate? = nil, useQueue : Bool = true){
        Log.delegate = delegate
        Log.useQueue = useQueue
        if !useQueue{
            queue.removeAll()
        }
    }

    public static func debug(_ string: String){
        if logLevel == .debug {
            log(string, level: .debug)
        }
    }
    
    public static func info(_ string: String){
        if logLevel <= .info {
            log(string, level: .info)
        }
    }
    
    public static func warn(_ string: String){
        if logLevel <= .warn {
            log(string, level: .warn)
        }
    }
    
    public static func error(_ string: String){
        if logLevel <= .error {
            log(string, level: .error)
        }
    }

    public static func error(error: Error){
        if logLevel <= .error {
            log(error.localizedDescription, level: .error)
        }
    }
    
    public static func log(_ string: String, level : LogLevel){
        let msg = level.logText + dateTimeFormatter.string(from: Date()) + " " + string
        if useConsoleOutput{
            print(msg)
        }
        if logFileUrl != nil {
            appendToLogFile(text: msg + "\n")
        }
        if useQueue {
            appendToQueue(msg: msg, level: level)
            delegate?.updateLog()
        }
    }

    public static func appendToLogFile(text: String){
        lock()
        defer{unlock()}
        if let url = logFileUrl{
            do{
                let fileHandle = try FileHandle(forWritingTo: url)
                if let data = text.data(using: .utf8){
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
            catch{
                print(error)
            }
        }
    }
    
    public static func appendToQueue(msg: String, level: LogLevel){
        lock()
        defer{unlock()}
        queue.append(LogChunk(msg, level: level))
    }
    
    public static func resetLogFile(){
        lock()
        defer{unlock()}
        if let url = logFileUrl{
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
    }

    private static func getDateTimeFormatter() -> DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }

    /**
      To be called by the delgate on updateLog, retrieved log chunks are removed from the queue
     - Returns: Array<LogChunk> if any chunks present, otherwise nil
     */
    public static func getChunks() -> Array<LogChunk>?{
        lock()
        defer{unlock()}
        if queue.isEmpty
        {
            return nil
        }
        let result = queue
        queue = Array<LogChunk>()
        return result
    }
    
}
