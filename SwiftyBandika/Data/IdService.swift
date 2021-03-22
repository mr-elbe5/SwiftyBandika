//
//  DataCenter.swift
//  
//
//  Created by Michael Rönnau on 25.01.21.
//

import Foundation

class IdService {

    static var instance = IdService()

    static func initialize(){
        //id
        if let s : String = Files.readTextFile(url: Paths.nextIdFile){
            instance.nextId = Int(s) ?? 1000
        }
        else{
            _ = Files.saveFile(text: String(instance.nextId), url: Paths.nextIdFile)
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
    
    func getNextId() -> Int{
        lockId()
        defer{unlockId()}
        idChanged = true;
        nextId += 1
        return nextId
    }
    
    func checkIdChanged() {
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
        Files.saveFile(text: String(nextId), url: Paths.nextIdFile)
    }
    
}



