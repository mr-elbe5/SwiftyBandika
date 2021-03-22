//
//  DiskFile.swift
//  
//
//  Created by Michael Rönnau on 30.01.21.
//

import Foundation

class DiskFile{
    
    var name: String
    var live: Bool
    var url: URL{
        get{
            URL(fileURLWithPath: name, relativeTo: live ? Paths.fileDirectory : Paths.tempFileDirectory)
        }
    }

    init(){
        name = ""
        live = false
    }
    
    init(name: String, live: Bool){
        self.name = name
        self.live = live
    }
    
    func exists() -> Bool{
        Files.fileExists(url: url)
    }

    func writeToDisk(_ memoryFile: MemoryFile) -> Bool{
        if Files.fileExists(url: url){
            _ = Files.deleteFile(url: url)
        }
        return Files.saveFile(data: memoryFile.data, url: url)
    }

    func makeLive(){
        if !live{
            let tmpUrl = url
            live = true
            if !Files.moveFile(fromURL: tmpUrl, toURL: url){
                Log.error("could not move file to live")
                live = false
            }
        }
    }
    
}
