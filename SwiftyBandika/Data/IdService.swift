/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class IdService {

    static public var instance = IdService()

    public static func initialize(){
        //id
        if let s : String = Files.readTextFile(path: Paths.nextIdFile){
            instance.nextId = Int(s) ?? 1000
        }
        else{
            _ = Files.saveFile(text: String(instance.nextId), path: Paths.nextIdFile)
        }
        instance.idChanged = false;
    }
    
    private var nextId : Int = 1000
    private var idChanged = false
    
    private let idSemaphore = DispatchSemaphore(value: 1)
    
    private func lockId(){
        idSemaphore.wait()
    }
    
    private func unlockId(){
        idSemaphore.signal()
    }
    
    public func getNextId() -> Int{
        lockId()
        defer{unlockId()}
        idChanged = true;
        nextId += 1
        return nextId
    }
    
    public func checkIdChanged() {
        lockId()
        defer{unlockId()}
        if (idChanged) {
            if !saveId(){
                Log.error("could not save id")
            }
            idChanged = false
        }
    }
    
    private func saveId() -> Bool{
        Files.saveFile(text: String(nextId), path: Paths.nextIdFile)
    }
    
}



