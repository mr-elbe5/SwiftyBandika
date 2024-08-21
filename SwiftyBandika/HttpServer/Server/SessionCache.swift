/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public struct SessionCache{

    public static var sessions = Dictionary<String, Session>()

    private static let semaphore = DispatchSemaphore(value: 1)

    public static func getSession(sessionId: String) -> Session{
        lock()
        defer{unlock()}
        var session = sessions[sessionId]
        if session != nil{
            session!.timestamp = Date()
        }
        else{
            var sessionId = ""
            repeat {
                sessionId = String.generateRandomString(length: 32)
            }
            while sessions.keys.contains(sessionId)
            session = Session()
            session?.sessionId = sessionId
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
