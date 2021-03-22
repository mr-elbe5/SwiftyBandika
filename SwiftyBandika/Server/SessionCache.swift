//
// Created by Michael Rönnau on 02.03.21.
//

import Foundation

struct SessionCache{

    static var sessions = Dictionary<String, Session>()

    private static let semaphore = DispatchSemaphore(value: 1)

    static func getSession(sessionId: String) -> Session{
        lock()
        defer{unlock()}
        var session = sessions[sessionId]
        if session != nil{
            //Log.info("found session \(session!.sessionId)")
            session!.timestamp = Date()
        }
        else{
            session = Session()
            Log.info("created new session with id \(session!.sessionId)")
            sessions[session!.sessionId] = session
        }
        return session!
    }

    private static func lock(){
        semaphore.wait()
    }

    private static func unlock(){
        semaphore.signal()
    }

}