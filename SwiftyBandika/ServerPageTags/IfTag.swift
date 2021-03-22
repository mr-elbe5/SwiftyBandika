//
// Created by Michael Rönnau on 21.02.21.
//

import Foundation

class IfTag: ServerPageTag{

    override class var type : TagType{
        .spgIf
    }

    override func getHtml(request: Request) -> String {
        if getBoolAttribute("condition", request) {
            return getChildHtml(request: request)
        }
        return ""
    }

}