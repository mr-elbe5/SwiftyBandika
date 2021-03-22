//
//  Log.swift
//  tomcatctrl
//
//  Created by Michael Rönnau on 06.12.20.
//

import Foundation

protocol LogDelegate {
    func appendLog(string : String, sender: Log)
}

class Log {
    
    var logURL : URL
    
    private var fileHandle: FileHandle? = nil
    private var eventSource: DispatchSourceFileSystemObject? = nil

    var delegate: LogDelegate?
    
    var isRunning : Bool{
        get{
            return eventSource != nil
        }
    }

    init(logURL : URL){
        self.logURL = logURL
    }

    deinit {
        stopLog()
    }
    
    func startLog(){
        do{
            let fileHandle = try FileHandle(forReadingFrom: logURL)
            let eventSource = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileHandle.fileDescriptor,
                eventMask: .extend,
                queue: DispatchQueue.main
            )
            eventSource.setEventHandler {
                let event = eventSource.data
                self.process(event: event)
            }
            eventSource.setCancelHandler {
                try? fileHandle.close()
            }
            fileHandle.seekToEndOfFile()
            eventSource.resume()
            self.fileHandle = fileHandle
            self.eventSource = eventSource
        }
        catch{
            
        }
    }
    
    func stopLog(){
        eventSource?.cancel()
        fileHandle = nil
        eventSource = nil
    }

    func process(event: DispatchSource.FileSystemEvent) {
        guard event.contains(.extend) else {
            return
        }
        if let newData = self.fileHandle?.readDataToEndOfFile(){
            let string = String(data: newData, encoding: .utf8)!
            self.delegate?.appendLog(string: string, sender: self)
        }
    }
    
}
