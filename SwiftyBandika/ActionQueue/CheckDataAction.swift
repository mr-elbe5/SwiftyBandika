//
// Created by Michael Rönnau on 17.03.21.
//

import Foundation

class CheckDataAction : QueuedAction{

    static var instance = CheckDataAction()

    static func addToQueue(){
        ActionQueue.instance.addAction(instance)
    }

    override var type : ActionType{
        get{
            .checkData
        }
    }

    override func execute() {
        print("checking data")
        IdService.instance.checkIdChanged()
        UserContainer.instance.checkChanged()
        ContentContainer.instance.checkChanged()
    }
}