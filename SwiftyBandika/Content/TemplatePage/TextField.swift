//
// Created by Michael Rönnau on 18.02.21.
//

import Foundation

class TextField : PartField{

    override var type : DataType{
        get{
            .textfield
        }
    }

    override func readRequest(_ request: Request) {
        content = request.getString(identifier)
    }

}