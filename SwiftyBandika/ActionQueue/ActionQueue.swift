/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

public class ActionQueue{

    public static var instance = ActionQueue()

    private var regularActions = Array<RegularAction>()
    private var actions = Array<QueuedAction>()

    private let semaphore = DispatchSemaphore(value: 1)

    public var timer: Timer? = nil

    private func lock(){
        semaphore.wait()
    }

    private func unlock(){
        semaphore.signal()
    }

    public func start(){
        if timer != nil{
            stop()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
            self.checkActions()
        }
        Log.info("action queue timer started")
    }

    public func stop(){
        timer?.invalidate()
        timer = nil
    }

    public func addRegularAction(_ action: RegularAction) {
        regularActions.append(action)
    }

    public func addAction(_ action: QueuedAction) {
        if !actions.contains(action) {
            actions.append(action)
        }
    }

    public func checkActions() {
        lock()
        defer{unlock()}
        for action in regularActions{
            action.checkNextExecution()
        }
        while !actions.isEmpty {
            let action = actions.removeFirst()
            Log.debug("executing action: \(action.type)")
            action.execute()
        }
    }

}
