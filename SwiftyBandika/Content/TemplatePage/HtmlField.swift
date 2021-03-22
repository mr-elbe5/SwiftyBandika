//
// Created by Michael Rönnau on 18.02.21.
//

import Foundation

class HtmlField : PartField{

    override var type : DataType{
        get{
            .htmlfield
        }
    }

    override func readRequest(_ request: Request) {
        content = request.getString(identifier)
    }
}