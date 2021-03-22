//
// Created by Michael Rönnau on 17.03.21.
//

import Foundation

class RegularAction : QueuedAction{

    var nextExecution:  Date

    override init(){
        nextExecution = App().currentTime
        super.init()
    }

    var intervalMinutes : Int{
        get{
            return 0
        }
    }

    var isActive : Bool{
        get{
            intervalMinutes != 0
        }
    }

    // other methods

    func checkNextExecution() {
        if isActive{
            let now = App().currentTime
            let next = nextExecution
            if now > next {
                ActionQueue.instance.addAction(self)
                let seconds = intervalMinutes * 60
                nextExecution = now + Double(seconds)
            }
        }
    }

}
