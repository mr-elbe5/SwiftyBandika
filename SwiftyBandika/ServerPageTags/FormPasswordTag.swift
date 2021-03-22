//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormPasswordTag : FormLineTag{

    override class var type: TagType {
        .spgFormPassword
    }

    override func getPreControlHtml(request: Request) -> String{
        """
        <input type="password" id="{{name}}" name="{{name}}" class="form-control" />
        """.format([
            "name" : name]
        )
    }

}