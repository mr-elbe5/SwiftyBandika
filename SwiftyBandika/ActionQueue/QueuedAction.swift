//
// Created by Michael Rönnau on 17.03.21.
//

import Foundation

enum ActionType{
    case none
    case cleanup
    case checkData
}

class QueuedAction: Identifiable, Equatable{

    static func == (lhs: QueuedAction, rhs: QueuedAction) -> Bool {
        lhs.type == rhs.type
    }

    var type : ActionType{
        get {
            return .none
        }
    }

    func execute(){
    }

}