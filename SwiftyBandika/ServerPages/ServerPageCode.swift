//
// Created by Michael Rönnau on 25.02.21.
//

import Foundation

class ServerPageCode: ServerPageNode{

    var code: String = ""

    override func getHtml(request: Request) -> String{
        code.format(request.pageVars)
    }

}