/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class DiskFile{
    
    public var name: String
    public var live: Bool
    public var path: String{
        get{
            (live ? Paths.fileDirectory : Paths.tempFileDirectory).appendPath(name)
        }
    }

    public init(){
        name = ""
        live = false
    }
    
    public init(name: String, live: Bool){
        self.name = name
        self.live = live
    }
    
    public func exists() -> Bool{
        Files.fileExists(path: path)
    }
    
    public func readFromDisk() -> MemoryFile?{
        if Files.fileExists(path: path), let data = Files.readFile(path: path){
            return MemoryFile(name: name, data: data)
        }
        return nil
    }

    public func writeToDisk(_ memoryFile: MemoryFile) -> Bool{
        if Files.fileExists(path: path){
            _ = Files.deleteFile(path: path)
        }
        return Files.saveFile(data: memoryFile.data, path: path)
    }

    public func makeLive(){
        if !live{
            let tmpPath = path
            live = true
            if !Files.moveFile(from: tmpPath, to: path){
                Log.error("could not move file to live")
                live = false
            }
        }
    }
    
}
