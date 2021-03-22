//
// Created by Michael Rönnau on 17.03.21.
//

import Foundation

class ActionQueue{

    static var instance = ActionQueue()

    private var regularActions = Array<RegularAction>()
    private var actions = Array<QueuedAction>()

    private let semaphore = DispatchSemaphore(value: 1)

    var timer: Timer? = nil

    private func lock(){
        semaphore.wait()
    }

    private func unlock(){
        semaphore.signal()
    }

    func start(){
        if timer == nil{
            stop()
        }
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(checkActions), userInfo: nil, repeats: true)
    }

    func stop(){
        timer?.invalidate()
        timer = nil
    }

    func addRegularAction(_ action: RegularAction) {
        regularActions.append(action)
    }

    func addAction(_ action: QueuedAction) {
        if !actions.contains(action) {
            actions.append(action)
        }
    }

    @objc func checkActions() {
        lock()
        defer{unlock()}
        for action in regularActions{
            action.checkNextExecution()
        }
        while !actions.isEmpty {
            let action = actions.removeFirst()
            action.execute()
        }
    }

}