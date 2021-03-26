/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class DiskFile{
    
    var name: String
    var live: Bool
    var path: String{
        get{
            (live ? Paths.fileDirectory : Paths.tempFileDirectory).appendPath(name)
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
        Files.fileExists(path: path)
    }

    func writeToDisk(_ memoryFile: MemoryFile) -> Bool{
        if Files.fileExists(path: path){
            _ = Files.deleteFile(path: path)
        }
        return Files.saveFile(data: memoryFile.data, path: path)
    }

    func makeLive(){
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
