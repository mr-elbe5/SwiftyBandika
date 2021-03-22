//
// Created by Michael Rönnau on 17.03.21.
//

import Foundation

class CleanupAction : RegularAction{

    override var type : ActionType{
        get{
            .cleanup
        }
    }
    override var intervalMinutes: Int {
        Preferences.instance.cleanupInterval
    }

    override func execute() {
        ContentContainer.instance.cleanupFiles()
    }
}