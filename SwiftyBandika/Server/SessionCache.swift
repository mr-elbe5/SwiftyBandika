/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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